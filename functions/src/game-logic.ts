import * as functions from "firebase-functions";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {firestore} from "firebase-admin";
import QuerySnapshot = firestore.QuerySnapshot;

export class GameLogic {
  static checkTurn(playerQueue: QuerySnapshot, playerId: string): [QueryDocumentSnapshot, QueryDocumentSnapshot] {
    const playersNumber: number = playerQueue.size;
    for (let i = 0; i < playersNumber; i++) {
      const playerDoc: QueryDocumentSnapshot = playerQueue.docs[i];
      if (playerDoc.get("currentTurn") === true) {
        if (Date.now() - playerDoc.updateTime.toMillis() < 42000) {
          if (playerDoc.id === playerId) {
            return [playerDoc, playerQueue.docs[(i+1) % playersNumber]];
          }
        }
      }
    }
    throw new functions.https.HttpsError("failed-precondition", "It's not your turn.");
  }

  static validateTiles(playerDoc: DocumentSnapshot): void {
    playerDoc.get("initialMeld");
  }
}
