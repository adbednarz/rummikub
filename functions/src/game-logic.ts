import * as functions from "firebase-functions";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {firestore} from "./index";
import {Tile} from "./model/tile";
import _ = require("lodash");

export class GameLogic {
  static async checkTurn(gameId: string, playerId: string): Promise<[QueryDocumentSnapshot, QueryDocumentSnapshot]> {
    const game: FirebaseFirestore.DocumentSnapshot = await firestore.collection("games/").doc(gameId).get();
    const playersQueue: FirebaseFirestore.QuerySnapshot =
        await firestore.collection("games/" + gameId + "/playersQueue").get();
    const playersNumber: number = playersQueue.size;
    for (let i = 0; i < playersNumber; i++) {
      const playerDoc: QueryDocumentSnapshot = playersQueue.docs[i];
      if (playerDoc.id === game.get("currentTurn")) {
        if (Date.now() - game.get("currentTurn").updateTime.toMillis() < 42000) {
          if (playerDoc.id === playerId) {
            return [playerDoc, playersQueue.docs[(i + 1) % playersNumber]];
          }
        }
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
                if (!_.isEqual(set, setFromPlayer)) {
                  this.validateSet(setsFromPlayer[counter]);
                  transaction.set(
                      snapshot.docs[counter].ref,
                      setFromPlayer
                  );
                  boardTiles = boardTiles.concat(Object.values(set));
                  playerTiles = playerTiles.concat(setsFromPlayer[counter]);
                } else {
                  if (!playerDoc.get("initilMeld")) {
                    throw new functions.https.HttpsError(
                        "failed-precondition", "You cannot manipulate sets at initial meld.!");
                  }
                }
              }
              counter++;
            }

            while (counter < setsFromPlayer.length) {
              this.validateSet(setsFromPlayer[counter]);
              transaction.set(
                  firestore.collection("games/" + gameId + "/board").doc(Date.now().toString()),
                  {...setsFromPlayer[counter]}
              );
              playerTiles = playerTiles.concat(setsFromPlayer[counter]);
              counter++;
            }

            if (playerTiles.length <= boardTiles.length) {
              throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
            }

            const difference = playerTiles.filter((x) => !boardTiles.some((y, index) => {
              if (_.isEqual(x, y)) {
                delete boardTiles[index];
                return true;
              }
              return false;
            }));

            functions.logger.log(difference);

            playerRack.forEach((tile) => {
              const currentTile: Tile = <Tile> tile.data();
              difference.some((x, index) => {
                if (_.isEqual(x, currentTile)) {
                  transaction.delete(tile.ref);
                  delete difference[index];
                }
              });
              if (difference.length === 0) {
                return;
              }
            });

            if (difference.length !== 0) {
              throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
            }
          });
    }));
  }

  static validateSet(set: Tile[]): void {
    if (!this.isRun(set) && !this.isGroup(set)) {
      throw new functions.https.HttpsError("failed-precondition", "Board is not valid!");
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
