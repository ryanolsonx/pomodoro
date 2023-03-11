port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Task
import Time



-- MAIN


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- PORTS


port notify : String -> Cmd msg



-- MODEL


type Kind
    = Pomodoro
    | ShortBreak
    | LongBreak


type alias Model =
    { pomodorosCompleted : Int
    , secondsLeft : Int
    , isRunning : Bool
    , kind : Kind
    }


minsToSecs m =
    m * 60


getMinutesFromSecondsLeft : Int -> Int
getMinutesFromSecondsLeft secondsLeft =
    floor <| toFloat secondsLeft / 60


getSecondsFromSecondsLeft =
    modBy 60


zeroPad n =
    let
        strN =
            String.fromInt n
    in
    if n < 10 then
        "0" ++ strN

    else
        strN


init : () -> ( Model, Cmd Msg )
init _ =
    ( { pomodorosCompleted = 0
      , secondsLeft = 5 --minsToSecs 25
      , isRunning = False
      , kind = Pomodoro
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | Start
    | Pause


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            if model.isRunning then
                if model.secondsLeft == 1 then
                    ( { model | secondsLeft = minsToSecs 25, isRunning = False }, notify "Timer is done." )

                else
                    ( { model | secondsLeft = model.secondsLeft - 1 }, Cmd.none )

            else
                ( model, Cmd.none )

        Start ->
            ( { model | isRunning = True }, Cmd.none )

        Pause ->
            ( { model | isRunning = False }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view model =
    let
        minutes =
            getMinutesFromSecondsLeft model.secondsLeft

        seconds =
            getSecondsFromSecondsLeft model.secondsLeft

        formattedTime =
            zeroPad minutes ++ ":" ++ zeroPad seconds

        title =
            formattedTime ++ " - Time to focus!"
    in
    { title = title
    , body =
        [ div []
            [ h1 [] [ text formattedTime ]
            , if model.isRunning then
                button [ onClick Pause ] [ text "Pause" ]

              else
                button [ onClick Start ] [ text "Start" ]
            ]
        ]
    }
