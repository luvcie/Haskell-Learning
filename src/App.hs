module App (
  AppConfig (..),
  startApp,
  simulateFrame,
) where

import Control.Monad (unless)
import System.Random (initStdGen)

import Apecs

import qualified Raylib.Core as RL
import qualified Raylib.Core.Textures as RL

import Paths_callsign_king

import App.Core
import App.Animation
import App.Combat
import App.Lerp
import App.Rendering
import App.Upgrades

--------------------------------------------------------------------------------

-- Initial settings for application
data AppConfig = AppConfig {
  title :: String,
  width :: Int,
  height :: Int,
  targetFPS :: Int
}


-- Creates a window with
startApp :: AppConfig -> IO ()
startApp config = simulate $ do
  initialise config
  run
  terminate


-- Simulates a the world forward a single cycle without creating a window
simulateFrame :: GameState -> Float -> System World ()
simulateFrame = update

--------------------------------------------------------------------------------

-- Initialise state of application
initialise :: AppConfig -> System World ()
initialise config = do
  window <- liftIO $ do
    RL.setTargetFPS (targetFPS config)
    RL.initWindow (width config) (height config) (title config)
  let load fp f = liftIO $ getDataFileName fp >>= f
  boardTex <- load "assets/chess_assets/board.png" $ \fp -> RL.loadTexture fp window
  piecesTex <- load "assets/chess_assets/pieces.png" $ \fp -> RL.loadTexture fp window
  boardShd <- load "assets/shaders/board.vs.glsl" $ \vsfp ->
              load "assets/shaders/board.fs.glsl" $ \fsfp ->
                RL.loadShader (Just vsfp) (Just fsfp) window
  generator <- initStdGen
  set global (
    Window (Just window),
    Textures {
      boardTexture = Just boardTex,
      pieceTexture = Just piecesTex
    },
    Shaders {
      boardShader = Just boardShd
    },
    RandomGenerator generator)
  beginCombat


-- Release resources and close application
terminate :: System World ()
terminate = do
  Window window <- get global
  mapM_ (liftIO . RL.closeWindow) window


-- Handle main loop of application
run :: System World ()
run = do
  dt <- liftIO RL.getFrameTime
  gameState <- get global
  handleEvents gameState dt
  update gameState dt
  render gameState
  shouldClose <- liftIO RL.windowShouldClose
  unless shouldClose run


-- Respond to user input
handleEvents :: GameState -> Float -> System World ()
handleEvents Combat = handleInputForCombat
handleEvents UpgradeMenu = handleInputForUpgradeMenu


-- Update application logic
update :: GameState -> Float -> System World ()
update gs dt = do
  updateLocationLerps dt
  updateAnimations dt
  case gs of
    Combat -> updateCombatLogic dt
    UpgradeMenu -> updateUpgradeMenuLogic dt


-- Render the application
render :: GameState -> System World ()
render Combat = whileRendering renderCombat renderCombatHud
render UpgradeMenu = whileRendering (pure ()) renderUpgradeMenu
