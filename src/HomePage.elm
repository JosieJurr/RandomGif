module HomePage exposing (..)

-- IMOPRTS
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)


-- MAIN

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- MODEL

type Model
  = Failure
  | Loading
  | Success String

init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getRandomGif)


-- UPDATE

type Msg
  = GenerateGif
  | GotGif (Result Http.Error String)

logoUrl : String
logoUrl =
  "https://www.ateamindia.com/wp-content/uploads/2019/06/elm2.png"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GenerateGif ->
      (Loading, getRandomGif)

    GotGif result ->
      case result of
        Ok url ->
          (Success url, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)
    

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ viewHeader 
        , viewContent model 
        , viewFooter ]
     
viewHeader : Html Msg
viewHeader =
    div [ class "header" ]
        [ viewLogo ]

viewContent : Model -> Html Msg
viewContent model =
    div [ class "content" ]
        [ button [ onClick GenerateGif ] [ text "Click me!" ]
        , viewGif model
        ]

viewFooter : Html Msg
viewFooter =
    div [ class "footer" ] []


viewLogo : Html Msg
viewLogo =
  div [ class "logo" ]
        [ img [ src logoUrl ] []
        ]

viewGif : Model -> Html Msg
viewGif model =
  case model of
    Failure ->
      div [ class "error" ]
        [ text "Something went horribly wrong. "
        , button [ onClick GenerateGif ] [ text "Try Again!" ]
        ]

    Loading ->
      div [ class "loading" ]
        [ div [class "spinner" ] []
        ]

    Success url ->
      div [ class "success" ]
        [ img [ src url ] []
        ]


-- HTTP

getRandomGif : Cmd Msg
getRandomGif =
  Http.get
    { url = "https://api.giphy.com/v1/gifs/random?api_key=gL3jwNUfDv110pHzs0JQTdlPMp30Sv7A"
    , expect = Http.expectJson GotGif gifDecoder
    }


gifDecoder : Decoder String
gifDecoder =
  field "data" (field "image_url" string)