import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {Game} from "./models/game";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const searchGame = functions.https.onCall((data, context) => {
  const playerID: string = context.auth?.uid ?? "";
  const size: number = data.playersNumber;
  let gameID: string;
  let searchedGame: Game;

  if (playerID === "") {
    throw new functions.https.HttpsError("failed-precondition",
        "The function must be called while authenticated.");
  }
  return firestore.runTransaction((transaction) => {
    return transaction.get(GameUtils.findGame(size))
        .then((gameResult) => {
          if (gameResult.size == 1) {
            const result = GameUtils.addToGame(
                transaction, playerID, gameResult
            );
            gameID = result[0];
            searchedGame = result[1];
          } else {
            gameID = GameUtils.createGame(transaction, playerID, size);
          }
          const userRef = firestore.collection("users").doc(playerID);
          transaction.update(userRef, {"active": false});
        });
  }).then(() => {
    if (searchedGame?.isFull) {
      GameUtils.startGame(gameID, searchedGame);
    }
    return {"gameID": gameID};
  });
});

