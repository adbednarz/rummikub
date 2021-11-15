import * as functions from "firebase-functions";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {firestore} from "./index";
import {Tile} from "./model/tile";
import _ = require("lodash");

export class GameLogic {
  static checkTurn(playerQueue: FirebaseFirestore.QuerySnapshot, playerId: string):
      [QueryDocumentSnapshot, QueryDocumentSnapshot] {
    const playersNumber: number = playerQueue.size;
    for (let i = 0; i < playersNumber; i++) {
      const playerDoc: QueryDocumentSnapshot = playerQueue.docs[i];
      if (playerDoc.get("currentTurn") === true) {
        // if (Date.now() - playerDoc.updateTime.toMillis() < 42000) {
        // if (playerDoc.id === playerId) {
        return [playerDoc, playerQueue.docs[(i+1) % playersNumber]];
        // }
        // }
      }
    }
    throw new functions.https.HttpsError("failed-precondition", "It's not your turn.");
  }

  static validateTiles(gameId: string, playerDoc: DocumentSnapshot, tiles: Tile[][]): void {
    firestore.collection("games/" + gameId + "/board").get()
        .then((snapshot) => {
          if (snapshot.docs.length < tiles.length) {
            throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
          }
          let i = 0;
          let boardTiles: Tile[] = [];
          let playerTiles: Tile[] = [];
          for (i; i < snapshot.docs.length; i++) {
            const set: Tile[] = Object.values(snapshot.docs[i].data());
            if (!_.isEqual(set, tiles[i])) {
              boardTiles = {...boardTiles, ...set};
              playerTiles = {...playerTiles, ...tiles[i]};
            }
          }
          for (i, i < tiles.length; i++) {
              playerTiles = {...playerTiles, ...tiles[i]};
          }
          playerTiles.
        });
    // firestore.collection("games/" + gameId + "/board").doc().set(

    // );
  }
}


