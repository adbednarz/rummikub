import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {GameLogic} from "./game-logic";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const searchGame = functions.https.onCall((data, context) => {
  const playerId: string = context.auth?.uid ?? "";
  const size: number = data.playersNumber;
  let gameId: string;
  let isGameFull: boolean;

  GameUtils.checkAuthentication(playerId);

  return firestore.runTransaction((transaction) => {
    return transaction.get(GameUtils.findGame(size))
        .then((gameResult) => {
          if (gameResult.size == 0) {
            gameId = GameUtils.createGame(transaction, playerId, size);
          } else {
            const result = GameUtils.addToGame(transaction, playerId, gameResult.docs[0]);
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

export const putTiles = functions.https.onCall((data, context) => {
  const playerId: string = context.auth?.uid ?? "";
  const gameId: string = data.gameId;
  // const board = data.newBoard;

  GameUtils.checkAuthentication(playerId);

  if (GameLogic.isPlayerTurn(playerId, gameId) && GameLogic.validateNewBoard(playerId, gameId)) {
    return {"response": true};
  } else {
    return {"response": false};
  }
});
