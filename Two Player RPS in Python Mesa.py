from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.datacollection import DataCollector
from mesa.visualization.modules import ChartModule, PieChartModule
from mesa.visualization.ModularVisualization import ModularServer
from mesa.visualization import Choice
import random

# Names the 3 pure strategies of RPS
CHOICES = ["rock", "paper", "scissors"]

# Defines the strategies including the pure strategies
STRATEGIES = ["random", "tit-for-tat", "beat last move", "win-stay-lose-shift"] + CHOICES

# Determines the winner of each round "step"
def determine_winner(player1_choice, player2_choice):
    if player1_choice == player2_choice:
        return 0  # Tie
    elif (player1_choice == "rock" and player2_choice == "scissors") or \
         (player1_choice == "scissors" and player2_choice == "paper") or \
         (player1_choice == "paper" and player2_choice == "rock"):
        return 1  # Player 1 wins
    else:
        return 2  # Player 2 wins

# Returns the choice that beats the given move of the previous round
def beat_last_move(move):
    if move == "rock":
        return "paper"
    elif move == "paper":
        return "scissors"
    elif move == "scissors":
        return "rock"

# Class of the agents
class PlayerAgent(Agent):
    def __init__(self, unique_id, model, strategy="random"):  # Sets random as the default strategy on the server
        super().__init__(unique_id, model)
        self.wins = 0  # Track the number of wins
        self.strategy = strategy
        self.choice = None
        self.last_choice = None


self.last_result = None  # Track the outcome of the last round (win, lose, tie)
self.choice_history = []

# Determines which move to make, based on the strategy
def decide(self):
    # Determines who is the opponent
    opponent = self.model.player1 if self.unique_id == 2 else self.model.player2
    if self.strategy == "win-stay-lose-shift":
        # If this is the first round, or if the agent won or tied the last round, it stays with its last choice (if any)
        if self.last_result in [None, 1, 0]:
            self.choice = self.last_choice if self.last_choice else random.choice(CHOICES)
        else:  # If the agent lost the last round, it shifts to the next choice
            next_index = (CHOICES.index(self.last_choice) + 1) % len(CHOICES)
            self.choice = CHOICES[next_index]
    elif self.strategy == "tit-for-tat":
        # For the first round, or if no history, choose randomly
        if not opponent.choice_history:
            self.choice = random.choice(CHOICES)
        else:
            # Mimic the opponent's last round choice
            self.choice = opponent.choice_history[-1]
    elif self.strategy == "beat last move":
        # For the first round, or if no history, choose randomly
        if not opponent.choice_history:
            self.choice = random.choice(CHOICES)
        else:
            # Choose what would have beaten the opponent's last round choice
            self.choice = beat_last_move(opponent.choice_history[-1])
    elif self.strategy == "random":
        # For random strategy choices
        self.choice = random.choice(CHOICES)
    else:
        # For pure strategy choices
        self.choice = self.strategy

# This function keeps track of the choices of each agent
def finalize_choice(self):
    self.last_choice = self.choice
    self.choice_history.append(self.choice)

# Class for the ABM
class RPSModel(Model):
    def __init__(self, player1_strategy="random", player2_strategy="random"):
        super().__init__()
        self.schedule = RandomActivation(self)
        self.player1 = PlayerAgent(1, self, strategy=player1_strategy)
        self.player2 = PlayerAgent(2, self, strategy=player2_strategy)
        self.schedule.add(self.player1)
        self.schedule.add(self.player2)
        self.ties = 0
        
        # Data collector for the server graphs
        self.datacollector = DataCollector(
            {
                "Player 1 Wins": lambda m: m.player1.wins,
                "Player 2 Wins": lambda m: m.player2.wins,
                "Difference in Wins": lambda m: m.player1.wins - m.player2.wins,
                "Ties": lambda m: m.ties,
            }
        )

    # Increment "step" function
    def step(self):
        # First, all agents decide their move
        self.player1.decide()
        self.player2.decide()
        
        # Determine the winner based on current decisions
        winner = determine_winner(self.player1.choice, self.player2.choice)
        
        # Update wins and the last result for each player based on the winner
        if winner == 1:
            self.player1.wins += 1
            self.player1.last_result = 1
            self.player2.last_result = 2
        elif winner == 2:
            self.player2.wins += 1
            self.player1.last_result = 2
            self.player2.last_result = 1
        else:
            self.ties += 1
            self.player1.last_result = 0
            self.player2.last_result = 0
        
        # After deciding and resolving the round, finalize choices for history
        self.player1.finalize_choice()
        self.player2.finalize_choice()


# Collect data after all actions are finalized
self.datacollector.collect(self)

# Log the choices to debug
print(f"Round {self.schedule.steps}: Player 1 chose {self.player1.choice}, Player 2 chose {self.player2.choice}")

# Create the choice dropdown fields on the LHS
model_params = {
    "player1_strategy": Choice(
        name="Player 1 Strategy",
        value="random",
        choices=STRATEGIES,
        description="Select Player 1's strategy",
    ),
    "player2_strategy": Choice(
        name="Player 2 Strategy",
        value="random",
        choices=STRATEGIES,
        description="Select Player 2's strategy",
    ),
}

# Creates the server containing the graphs
server = ModularServer(
    RPSModel,
    [
        ChartModule(
            [
                {"Label": "Player 1 Wins", "Color": "Blue"},
                {"Label": "Player 2 Wins", "Color": "Red"},
                {"Label": "Ties", "Color": "Green"},
            ],
            datacollector_name='datacollector'
        ),
        ChartModule(
            [{"Label": "Difference in Wins", "Color": "Purple"}],
            datacollector_name='datacollector'
        ),
        PieChartModule(
            [
                {"Label": "Player 1 Wins", "Color": "Blue"},
                {"Label": "Player 2 Wins", "Color": "Red"},
                {"Label": "Ties", "Color": "Green"},
            ],
            datacollector_name='datacollector'
        )
    ],
    "Rock Paper Scissors Game",
    model_params
)

# Ensure this port is free or change it to an available one
server.port = 8521

# Runs the server locally
server.launch()
