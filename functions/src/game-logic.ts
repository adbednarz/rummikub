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

  static addNewTiles(gameId: string, playerDoc: DocumentSnapshot,
      playerRack: FirebaseFirestore.QuerySnapshot, setsFromPlayer: Tile[][]): void {
    firestore.runTransaction(((transaction) => {
      return transaction.get(firestore.collection("games/" + gameId + "/board"))
          .then((snapshot) => {
            if (snapshot.docs.length > setsFromPlayer.length) {
              throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
            }
            let counter = 0;
            let boardTiles: Tile[] = [];
            let playerTiles: Tile[] = [];

            while (counter < snapshot.docs.length) {
              if (setsFromPlayer[counter].length == 0) {
                transaction.delete(snapshot.docs[counter].ref);
              } else {
                const set: FirebaseFirestore.DocumentData = snapshot.docs[counter].data();
                const setFromPlayer = {...setsFromPlayer[counter]};
                if (_.isEqual(set, setFromPlayer)) {
                  // this.validateSet(setsFromPlayer[counter]);
                  transaction.update(
                      snapshot.docs[counter].ref,
                      setFromPlayer
                  );
                  boardTiles = boardTiles.concat(Object.values(set)
                      .filter((x) => setsFromPlayer[counter].includes(x)));
                  playerTiles = playerTiles.concat(setsFromPlayer[counter]
                      .filter((x) => Object.values(set).includes(x)));
                  functions.logger.log(boardTiles);
                  functions.logger.log(playerTiles);
                  functions.logger.log([{name: "tak"}].includes({name: "tak"}));
                }
              }
              counter++;
            }

            while (counter < setsFromPlayer.length) {
              // this.validateSet(setsFromPlayer[counter]);
              transaction.set(
                  firestore.collection("games/" + gameId + "/board").doc(Date.now().toString()),
                  {...setsFromPlayer[counter]}
              );
              playerTiles = {...playerTiles, ...setsFromPlayer[counter]};
              counter++;
            }
            /* let difference = Object.values(playerTiles).filter((x) => !boardTiles.includes(x));
            playerRack.forEach((tile) => {
              const currentTile: Tile = <Tile> tile.data();
              for (let i = 0; i < difference.length; i++) {
                const diff = Object.values(difference).filter((x) => !_.isEqual(x, currentTile));
                if (diff.length !== difference.length) {
                  transaction.delete(tile.ref);
                  difference = diff;
                }
              }
            });
            if (difference.length !== 0) {
              throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
            }*/
          });
    }));
  }

  static validateSet(set: Tile[]): void {
    if (!this.isRun(set) && !this.isGroup(set)) {
      throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
    }
  }

  static isRun(set: Tile[]): boolean {
    for (let i = 0; i < set.length - 1; i++) {
      if (set[i].number + 1 !== set[i+1].number || set[i].color !== set[i+1].color) {
        return false;
      }
    }
    return true;
  }

  static isGroup(set: Tile[]): boolean {
    const uniqueColors = new Set(set.map((tile) => tile.color));
    const uniqueNumbers = new Set(set.map((tile) => tile.number));
    return set.length < 5 && (uniqueColors.size === 3 || uniqueColors.size === 4) && uniqueNumbers.size === 1;
  }
}
