import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {GameLogic} from "./game-logic";
import {QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {Tile} from "./model/tile";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const searchGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = context.auth?.token.name ?? null;
  const size: number = data.playersNumber;
  let gameId: string;
  let isGameFull: boolean;

  return firestore.runTransaction((transaction) => {
    return transaction.get(GameUtils.findGame(size))
        .then((gameResult) => {
          if (gameResult.size == 0) {
            gameId = GameUtils.createGame(transaction, playerId, playerName, size);
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
      firestore.collection("games").doc(gameId).update({winner: [currentPlayer.id]});
    } else if (result === "empty") {
      GameLogic.getTileFromPool(gameId, playerId).then((result) => {
        if (!result) {
          GameLogic.pointTheWinner(game, playersQueue);
        }
      });
    }
  });
});

export const leftGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const gameId: string = data.gameId;

  firestore.collection("games/" + gameId + "/playersRacks/" + playerId + "/rack").get()
      .then((snapshot) => {
        snapshot.docs.forEach((doc) => doc.ref.delete());
      });

  firestore.collection("games").doc(gameId).get().then((snapshotGame) => {
    if (snapshotGame.get("currentTurn") === playerId) {
      snapshotGame.ref.collection("playersQueue").get().then((snapshotQueue) => {
        for (let i = 0; i < snapshotQueue.docs.length; i++) {
          if (snapshotQueue.docs[i].id === playerId) {
            snapshotGame.ref.update({"currentTurn": snapshotQueue.docs[(i + 1) % snapshotQueue.size].id});
            break;
          }
        }
        firestore.collection("games/" + gameId + "/playersQueue").doc(playerId).delete();
      });
    } else {
      firestore.collection("games/" + gameId + "/playersQueue").doc(playerId).delete();
    }
  });
});

