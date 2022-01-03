import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {GameLogic} from "./game-logic";
import {Tile} from "./model/tile";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const createGame = functions.region("europe-central2").https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = data.playerName;
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

export const searchGame = functions.region("europe-central2").https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = data.playerName;
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

export const addToExistingGame = functions.region("europe-central2").https.onCall( (data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = data.playerName;
  const gameId: string = data.gameId;
  const accepted: boolean = data.accepted;

  firestore.collection("users").doc(playerId).update({"invitation": admin.firestore.FieldValue.delete()});
  let isGameFull: boolean;

  return firestore.runTransaction((transaction) => {
    return transaction.get(firestore.collection("games").doc(gameId))
        .then((gameResult) => {
          if (accepted) {
            const result = GameUtils.addToGame(transaction, playerId, playerName, gameResult);
            isGameFull = result[1];
          } else {
            const availablePlaces: number = gameResult.get("available") - 1;
            if (availablePlaces > 0) {
              transaction.update(gameResult.ref, {available: availablePlaces});
            }
            isGameFull = availablePlaces == 0;
          }
        });
  }).then(() => {
    if (isGameFull) {
      GameUtils.startGame(gameId);
    }
  });
});

export const putTiles = functions.region("europe-central2").https.onCall(async (data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const gameId: string = data.gameId;
  const sets: Record<string, Tile[]> = data.newBoard;

  const game: FirebaseFirestore.DocumentSnapshot = await firestore.collection("games").doc(gameId).get();

  await firestore.runTransaction(async (transaction) => {
    const playersQueue = await transaction.get(firestore.collection("games/" + gameId + "/playersQueue"));
    const players = await GameLogic.checkTurn(game, playersQueue, playerId);
    const currentPlayerRack: FirebaseFirestore.QuerySnapshot =
        await firestore.collection("games/" + gameId + "/playersRacks/" + players[0].id + "/rack").get();

    await GameLogic.addNewTiles(gameId, players[0], currentPlayerRack, sets).then((result) => {
      if (result === "winner") {
        GameLogic.endGame(game, [players[0].id], playersQueue);
      } else if (result === "empty") {
        GameLogic.getTileFromPool(gameId, playerId).then(async (result) => {
          if (!result) {
            const winners = await GameLogic.pointTheWinner(game, playersQueue);
            GameLogic.endGame(game, winners, playersQueue);
          }
        });
      }
    });
    transaction.update(firestore.collection("games").doc(gameId), {currentTurn: players[1].id});
  });
});

export const leftGame = functions.region("europe-central2").https.onCall((data, context) => {
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

    // w przypadku, gdy po odejściu gracza zostaje tylko jeden, oboje wychodzą z gry
    if (playersQueue.size == 2) {
      await firestore.collection("users").doc(playersQueue.docs[0].id).update({"active": true});
      await firestore.collection("users").doc(playersQueue.docs[1].id).update({"active": true});
    } else {
      await firestore.collection("users").doc(playerId).update({"active": true});
    }

    await firestore.collection("games/" + gameId + "/playersQueue").doc(playerId).delete();
  });
});

