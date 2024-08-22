#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
echo -e "\n=~~~ Number Guessing Game ~~~\n"
echo "Enter your username:"
read USER_NAME
USERNAME=$($PSQL "SELECT name FROM number_guess WHERE name = '$USER_NAME'");

GAME_RESULTS() {

  TRIES=$1
  SECRET_NUMBER=$1

  echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

  USERNAME=$($PSQL "SELECT name FROM number_guess WHERE name = '$USER_NAME'");
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE name = '$USER_NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE name = '$USER_NAME'")

  NEW_GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

  if [[ $BEST_GAME -lt $TRIES && $BEST_GAME -ne 0 ]]
  then
    echo "Current best game is less than count"
    INSERT_DATA=$($PSQL "UPDATE number_guess SET games_played = '$NEW_GAMES_PLAYED' WHERE name = '$USERNAME'") 
  else
    echo "New best game"
    INSERT_GAMES_PLAYED=$($PSQL "UPDATE number_guess SET games_played = '$NEW_GAMES_PLAYED' WHERE name = '$USERNAME'")
    INSERT_BEST_GAME=$($PSQL "UPDATE number_guess SET best_game = '$TRIES' WHERE name = '$USERNAME'")
  fi
}

PLAY_GAME() {
  SECRET_NUMBER=$(( RANDOM % 10 + 1 ))

  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS

  TRIES=0

  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      TRIES=$((TRIES + 1))
    else
      echo "It's lower than that, guess again:"
      TRIES=$((TRIES + 1))
    fi
    read GUESS
  done
  TRIES=$((TRIES + 1))
  GAME_RESULTS $TRIES $SECRET_NUMBER
}

if [[ -z $USERNAME ]]
then
  echo Welcome, $USER_NAME! It looks like this is your first time here.
  INSERT_USER_NAME=$($PSQL "INSERT INTO number_guess (name, games_played, best_game) VALUES ('$USER_NAME', '0', '0')")
  PLAY_GAME
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE name = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE name = '$USERNAME'")
  echo -e "\eWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  PLAY_GAME
fi






