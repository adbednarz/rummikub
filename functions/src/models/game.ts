export interface Game {
    isFull: boolean;
    size: number;
    players: {[p: string]: Player};
}

export interface Player {
    currentTurn: boolean;
    initialMeld: boolean;
}
