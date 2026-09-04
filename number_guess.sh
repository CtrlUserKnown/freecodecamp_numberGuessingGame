#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read -r USERNAME
SQL_USERNAME=${USERNAME//\'/\'\'}

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$SQL_USERNAME';")

if [[ -n $USER_DATA ]]; then
  GAMES_PLAYED=$(echo "$USER_DATA" | cut -d'|' -f1)
  BEST_GAME=$(echo "$USER_DATA" | cut -d'|' -f2)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$SQL_USERNAME', 0, 0);" >/dev/null
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
while read -r GUESS; do
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
  if (( GUESS == SECRET_NUMBER )); then
    break
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

$PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN best_game = 0 OR $NUMBER_OF_GUESSES < best_game THEN $NUMBER_OF_GUESSES ELSE best_game END WHERE username='$SQL_USERNAME';" >/dev/null
