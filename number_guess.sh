#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$((RANDOM%1000+1))
echo -e "\nWelcome to Number Guessing Game\n"

NUMBER_GUESS(){
  echo "Enter your username:"
  read USERNAME
  NAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
  if [[ -z $NAME ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
    GAMES_PLAYED=0
  else
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE player_id=$PLAYER_ID")
    BEST_GAME=$($PSQL "SELECT num_of_guesses FROM games WHERE player_id=$PLAYER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  echo -e "\nGuess the secret number between 1 and 1000:"
  read NUM

  NUMBER_OF_GUESSES=1
  
  until [[ $NUM == $SECRET_NUMBER ]]
  do
    if [[ ! $NUM =~ ^[0-9]+$ ]]
    then
      (( NUMBER_OF_GUESSES++ ))
      echo "That is not an integer, guess again:"
      read NUMBER
      NUM=$NUMBER
    else
      (( NUMBER_OF_GUESSES++ ))
      if (($NUM < $SECRET_NUMBER))
      then
        echo "It's higher than that, guess again:"
        read NUMBER
        NUM=$NUMBER
      else
        echo "It's lower than that, guess again:"
        read NUMBER
        NUM=$NUMBER
      fi
    fi
  done
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUM. Nice job!"
  (( GAMES_PLAYED++ ))
  if (($GAMES_PLAYED == 1))
  then
    INSERT_FINAL_RESULT=$($PSQL "INSERT INTO games(player_id,games_played,num_of_guesses) VALUES($PLAYER_ID,$GAMES_PLAYED,$NUMBER_OF_GUESSES)")
  else
    
    if (($BEST_GAME > $NUMBER_OF_GUESSES))
    then
      UPDATE_RESULT=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED,num_of_guesses=$NUMBER_OF_GUESSES WHERE player_id=$PLAYER_ID")
    else
      UPDATE_RESULT=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED WHERE player_id=$PLAYER_ID")
    fi
  fi
}

NUMBER_GUESS
