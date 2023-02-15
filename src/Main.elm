module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Timer
    = Idle
    | Running
    | Paused


type alias Model =
    { secondsLeft : Int
    , timer : Timer
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { secondsLeft = 60
      , timer = Idle
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | StartTimer
    | PauseTimer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            case model.timer of
                Idle ->
                    (model, Cmd.none)

                Paused ->
                    (model, Cmd.none)

                Running ->
                    if model.secondsLeft == 1 then
                        ({ model | secondsLeft = 60, timer = Idle }, Cmd.none)
                    else
                        ({ model | secondsLeft = model.secondsLeft - 1 }, Cmd.none )

        StartTimer ->
            ( { model | timer = Running }, Cmd.none )

        PauseTimer ->
            ( { model | timer = Paused }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    let
        seconds =
            String.fromInt model.secondsLeft
    in
    div []
        [ h1 [] [ text seconds ]
        , case model.timer of
            Idle ->
              button [ onClick StartTimer ] [ text "Start" ]
            Running ->
              button [ onClick PauseTimer ] [ text "Pause" ]
            Paused ->
              button [ onClick StartTimer ] [ text "Resume" ]
        ]
