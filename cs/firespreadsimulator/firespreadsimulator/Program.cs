string fileName = "forest_grid_1.txt";
char[,] fireSpreadGrid = new char[4, 4];
List<Vector2i> firePositions = new();
int regenerationStage = 0;

//enterPath();

Vector2i[] CardinalDirections = {
    new Vector2i(-1,  0), // left
    new Vector2i( 1,  0), //right
    new Vector2i( 0,  1), // up
    new Vector2i( 0, -1) // down
};

try {
    using StreamReader sr = new(fileName);
    string line;
    int yPos = 0;
    bool firstLineDrawn = false;

    while ((line = sr.ReadLine()) != null) {
        // check if area is defined
        if (!firstLineDrawn) {
            firstLineDrawn = true;
            string[] possibleAreaDefinition = line.Split(' ');
            if (possibleAreaDefinition.Length == 2 && int.TryParse(possibleAreaDefinition[0], out int height) && int.TryParse(possibleAreaDefinition[1], out int width)) {
                fireSpreadGrid = new char[width, height];
            }
            printBar(fireSpreadGrid.GetLength(0));
            continue;
        }
        Console.Write("|");
        for (int i = 0; i < fireSpreadGrid.GetLength(0) + (fireSpreadGrid.GetLength(0) - 1); i++) {
            char currentPosValue = line[i];
            if (currentPosValue != ' ') {
                if (currentPosValue == 'F') {
                    firePositions.Add(new Vector2i(i / 2, yPos));
                }
                fireSpreadGrid[i / 2, yPos] = currentPosValue;
            }
            Console.Write(currentPosValue);
        }
        Console.Write("|");
        yPos++;
        Console.WriteLine();
    }
    printBar(fireSpreadGrid.GetLength(0));
} catch (Exception e) {
    Console.WriteLine("The file could not be read:");
    Console.WriteLine(e.Message);
    Console.WriteLine("Press any key to enter a valid txt.");
    Console.ReadKey();
    enterPath();
}

bool validInitialSquare = false;
while (!validInitialSquare) {
    Console.WriteLine("Please enter a square to set on fire! Eg: X,Y");
    string[] initialFireSquareInputSplit = Console.ReadLine().Split(',');
    
    if (!int.TryParse(initialFireSquareInputSplit[0], out int x)) {
        Console.WriteLine("Your X value was invalid!");
        continue;
    }

    if (!int.TryParse(initialFireSquareInputSplit[1], out int y)) {
        Console.WriteLine("Your Y value is invalid!");
        continue;
    }

    addFirePosition(new Vector2i(x, y));
    validInitialSquare = true;
}

regenerateFireSpreadGrid();

void enterPath() {
    while (!File.Exists(fileName)) {
        Console.Clear();
        Console.WriteLine("Please enter the name of a valid file to read!");
        fileName = Console.ReadLine();
    }
}

void printBar(int gridSizeX) {
    Console.WriteLine("+" + new string('-', gridSizeX + (gridSizeX - 1)) + "+");
}

void regenerateFireSpreadGrid() {
    printBar(fireSpreadGrid.GetLength(0));
    for (int y = 0; y < fireSpreadGrid.GetLength(1); y++) {
        Console.Write("|");
        for (int x = 0; x < fireSpreadGrid.GetLength(0); x++) {
            Console.Write(fireSpreadGrid[x, y]);
            if (x < fireSpreadGrid.GetLength(0) - 1) {
                Console.Write(" ");
            }
        }
        Console.Write("|");
        Console.WriteLine();
    }
    printBar(fireSpreadGrid.GetLength(1));
    if (updateFire()) {
        regenerateFireSpreadGrid();
    }

}

// true if values changed
bool updateFire() {
    bool changesMade = false;
    List<Vector2i> fireQueue = new();

    foreach (Vector2i position in firePositions) {
        foreach (Vector2i direction in CardinalDirections) {
            Vector2i newCoordinate = position + direction;
            if (newCoordinate.X < fireSpreadGrid.GetLength(0)
                && newCoordinate.X >= 0
                && newCoordinate.Y < fireSpreadGrid.GetLength(1)
                && newCoordinate.Y >= 0
                && fireSpreadGrid[newCoordinate.X, newCoordinate.Y] == 'T')
            {
                changesMade = true;
                fireQueue.Add(new Vector2i(newCoordinate.X, newCoordinate.Y));
            }
        }
    }

    foreach (Vector2i position in fireQueue) {
        addFirePosition(position);
    }
    return changesMade;
}

void addFirePosition(Vector2i position) {
    fireSpreadGrid[position.X, position.Y] = 'F';
    firePositions.Add(position);
}

struct Vector2i(int x, int y) {
    public int X { get; set; } = x;
    public int Y { get; set; } = y;

    public static Vector2i operator +(Vector2i vector1, Vector2i vector2) {
        return new Vector2i(vector1.X + vector2.X, vector1.Y + vector2.Y);
    }
    public override readonly string ToString() => $"({X}, {Y})";
}

struct GridPosition(Vector2i pos, char type) {
    public Vector2i POS { get; set; } = pos;
    public char TYPE { get; set; } = type;
}