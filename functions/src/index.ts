import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {Game} from "./models/game";
import {GameLogic} from "./game-logic";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const searchGame = functions.https.onCall((data, context) => {
  const playerId: string = context.auth?.uid ?? "";
  const size: number = data.playersNumber;
  let gameId: string;
  let searchedGame: Game;

  GameUtils.checkAuthentication(playerId);

  return firestore.runTransaction((transaction) => {
    return transaction.get(GameUtils.findGame(size))
        .then((gameResult) => {
          if (gameResult.size == 1) {
            const result = GameUtils.addToGame(transaction, playerId, gameResult);
            gameId = result[0];
            searchedGame = result[1];
          } else {
            gameId = GameUtils.createGame(transaction, playerId, size);
          }
          const userRef = firestore.collection("users").doc(playerId);
          transaction.update(userRef, {"active": false});
        });
  }).then(() => {
    if (searchedGame?.isFull) {
      GameUtils.startGame(gameId, searchedGame);
    }
    return {"gameId": gameId};
  });
});

export const putTitles = functions.https.onCall((data, context) => {
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
