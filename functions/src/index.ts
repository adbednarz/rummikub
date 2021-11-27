import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {GameLogic} from "./game-logic";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
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

  const game: FirebaseFirestore.DocumentSnapshot = await firestore.collection("games/").doc(gameId).get();
  const playersQueue: FirebaseFirestore.QuerySnapshot =
      await firestore.collection("games/" + gameId + "/playersQueue").get();

  const result: [QueryDocumentSnapshot, QueryDocumentSnapshot] =
      await GameLogic.checkTurn(game, playersQueue, playerId);
  const currentPlayer: DocumentSnapshot = result[0];
  const nextPlayer: DocumentSnapshot = result[1];
  const currentPlayerRack: FirebaseFirestore.QuerySnapshot =
       await firestore.collection("games/" + gameId + "/playersRacks/" + currentPlayer.id + "/rack").get();

  GameLogic.addNewTiles(gameId, currentPlayer, currentPlayerRack, sets).then(async (result) => {
    if (result === "added") {
      firestore.collection("games/").doc(gameId).update({currentTurn: nextPlayer.id});
    } else if (result === "winner") {
      firestore.collection("games/").doc(gameId).update({winner: currentPlayer.id});
    } else {
      const result = await GameLogic.getTileFromPool(gameId, playerId);
      if (!result) {
        GameLogic.pointTheWinner(game, playersQueue);
      }
    }
  });
});


