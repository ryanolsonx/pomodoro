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



-- TIME


getFormattedTime secondsLeft =
    let
        minutes =
            getMinutesFromSecondsLeft secondsLeft

        seconds =
            getSecondsFromSecondsLeft secondsLeft
    in
    zeroPad minutes ++ ":" ++ zeroPad seconds


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



-- KIND


getSecondsToTimeForKind kind =
    case kind of
        Pomodoro ->
            2

        ShortBreak ->
            5

        LongBreak ->
            10


getNameForKind kind =
    case kind of
        Pomodoro ->
            "Pomodoro"

        ShortBreak ->
            "Short Break"

        LongBreak ->
            "Long Break"


getNotificationTextForKind kind =
    case kind of
        Pomodoro ->
            "Time to focus!"

        ShortBreak ->
            "Time for a short break"

        LongBreak ->
            "Time for a long break"



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


init : () -> ( Model, Cmd Msg )
init _ =
    ( { pomodorosCompleted = 0
      , secondsLeft = getSecondsToTimeForKind Pomodoro
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


getNextKind model =
    let
        nextPomodorosCompleted =
            if model.kind == Pomodoro then
                model.pomodorosCompleted + 1

            else
                model.pomodorosCompleted

        nextKind =
            case model.kind of
                Pomodoro ->
                    if modBy 4 nextPomodorosCompleted == 0 then
                        LongBreak

                    else
                        ShortBreak

                -- TODO: how to go to long break.
                ShortBreak ->
                    Pomodoro

                LongBreak ->
                    Pomodoro

        seconds =
            getSecondsToTimeForKind nextKind
    in
    { model
        | kind = nextKind
        , secondsLeft = seconds
        , isRunning = False
        , pomodorosCompleted = nextPomodorosCompleted
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            if model.isRunning then
                if model.secondsLeft == 1 then
                    let
                        nextModel =
                            getNextKind model

                        notification =
                            getNotificationTextForKind nextModel.kind
                    in
                    ( nextModel, notify notification )

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
        kindName =
            getNameForKind model.kind

        time =
            getFormattedTime model.secondsLeft

        title =
            time ++ " - " ++ getNotificationTextForKind model.kind
    in
    { title = title
    , body =
        [ div []
            [ h1 []
                [ text kindName
                ]
            , h2 [] [ text time ]
            , if model.isRunning then
                button [ onClick Pause ] [ text "Pause" ]

              else
                button [ onClick Start ] [ text "Start" ]
            ]
        ]
    }
