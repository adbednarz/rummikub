import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {GameLogic} from "./game-logic";
import {QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {Tile} from "./model/tile";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const createGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = context.auth?.token.name ?? "";
  const players: string[] = data.playersSelected;
  const timeForMove: number = data.timeForMove;
  let gameId: string;

  return firestore.runTransaction((transaction) => {
    return transaction.get(firestore.collection("users").where("name", "in", players))
        .then(async (playersResult) => {
          // size jest równy 1, żeby gracze niezaproszeni nie mogli dołączać
          gameId = GameUtils.createGame(transaction, playerId, playerName, players.length, 0, timeForMove);
          playersResult.forEach((doc) => {
            doc.ref.update({"invitation": {"gameId": gameId, "player": playerName}});
          });
        });
  }).then(() => {
    return {"gameId": gameId};
  });
});

export const searchGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = context.auth?.token.name ?? "";
  const size: number = data.playersNumber;
  const timeForMove: number = data.timeForMove;
  let gameId: string;
  let isGameFull: boolean;

  return firestore.runTransaction((transaction) => {
    return transaction.get(GameUtils.findGame(size, timeForMove))
        .then((gameResult) => {
          if (gameResult.size == 0) {
            gameId = GameUtils.createGame(transaction, playerId, playerName, size - 1, size, timeForMove);
          } else {
            const result = GameUtils.addToGame(transaction, playerId, playerName, gameResult.docs[0]);
            gameId = result[0];
            isGameFull = result[1];
          }
        });
  }).then(() => {
    if (isGameFull) {
      GameUtils.startGame(gameId);
    }
    return {"gameId": gameId};
  });
});

export const addToExistingGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = context.auth?.token.name ?? null;
  const gameId: string = data.gameId;
  const accepted: boolean = data.accepted;

  firestore.collection("users").doc(playerId).update({"invitation": admin.firestore.FieldValue.delete()});

  return firestore.runTransaction((transaction) => {
    return transaction.get(firestore.collection("games").doc(gameId))
        .then((gameResult) => {
          let isGameFull: boolean;
          if (accepted) {
            const result = GameUtils.addToGame(transaction, playerId, playerName, gameResult);
            isGameFull = result[1];
          } else {
            const availablePlaces: number = gameResult.get("available") - 1;
            transaction.update(gameResult.ref, {available: availablePlaces});
            isGameFull = availablePlaces == 0;
          }
          if (isGameFull) {
            GameUtils.startGame(gameId);
          }
        });
  });
});

export const putTiles = functions.https.onCall(async (data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const gameId: string = data.gameId;
  const sets: Record<string, Tile[]> = data.newBoard;

  const game: FirebaseFirestore.DocumentSnapshot = await firestore.collection("games").doc(gameId).get();

  const result: [QueryDocumentSnapshot, FirebaseFirestore.QuerySnapshot] =
      await firestore.runTransaction(async (transaction) => {
        const playersQueue = await transaction.get(firestore.collection("games/" + gameId + "/playersQueue"));
        const players = await GameLogic.checkTurn(game, playersQueue, playerId);
        const currentPlayer: QueryDocumentSnapshot = players[0];
        const nextPlayer: QueryDocumentSnapshot = players[1];
        transaction.update(firestore.collection("games").doc(gameId), {currentTurn: nextPlayer.id});
        return [currentPlayer, playersQueue];
      });

  const currentPlayer = result[0];
  const playersQueue = result[1];
  const currentPlayerRack: FirebaseFirestore.QuerySnapshot =
       await firestore.collection("games/" + gameId + "/playersRacks/" + currentPlayer.id + "/rack").get();

  GameLogic.addNewTiles(gameId, currentPlayer, currentPlayerRack, sets).then((result) => {
    if (result === "winner") {
      GameLogic.endGame(game, [currentPlayer.id], playersQueue);
    } else if (result === "empty") {
      GameLogic.getTileFromPool(gameId, playerId).then(async (result) => {
        if (!result) {
          const winners = await GameLogic.pointTheWinner(game, playersQueue);
          GameLogic.endGame(game, winners, playersQueue);
        }
      });
    }
  });
});

export const leftGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const gameId: string = data.gameId;

  firestore.collection("games").doc(gameId).get().then(async (snapshotGame) => {
    const playersQueue: FirebaseFirestore.QuerySnapshot = await snapshotGame.ref.collection("playersQueue").get();
    if (snapshotGame.get("currentTurn") === playerId) {
      for (let i = 0; i < playersQueue.docs.length; i++) {
        if (playersQueue.docs[i].id === playerId) {
          await snapshotGame.ref.update({"currentTurn": playersQueue.docs[(i + 1) % playersQueue.size].id});
          break;
        }
      }
    }

    // w przypadku, gdy po odejściu gracza zostaje tylko jeden oboje wychodzą z gry
    if (playersQueue.size == 2) {
      await firestore.collection("users").doc(playersQueue.docs[0].id).update({"active": true});
      await firestore.collection("users").doc(playersQueue.docs[1].id).update({"active": true});
    } else {
      await firestore.collection("users").doc(playerId).update({"active": true});
    }

    await firestore.collection("games/" + gameId + "/playersQueue").doc(playerId).delete();
  });
});

