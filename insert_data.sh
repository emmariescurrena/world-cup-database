#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

here="$(dirname "$0")"

INFILE="$here"/games.csv

  
echo $($PSQL "TRUNCATE TABLE games, teams;
      ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;
      ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")

{
    read
    while IFS=, read -r year round winner opponent winner_goals opponent_goals
    do 
        echo $($PSQL "BEGIN;
          insert into teams(name) values('$winner') on conflict (name) do nothing;
          insert into teams(name) values('$opponent') on conflict (name) do nothing;
          insert into games(year, round, winner_goals, opponent_goals, winner_id, opponent_id)
          values(
          $year,
          '$round',
          $winner_goals,
          $opponent_goals,
          (select team_id from teams where name = '$winner'),
          (select team_id from teams where name = '$opponent')
          );
          COMMIT;")
    done
} < "$INFILE"