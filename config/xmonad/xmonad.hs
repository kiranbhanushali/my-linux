import System.IO
import System.Exit
import qualified Data.List as L
import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Layout.Gaps
import XMonad.Layout.Fullscreen( fullscreenEventHook , fullscreenManageHook , fullscreenSupport , fullscreenFull ) 
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.Circle
import XMonad.Layout.CenteredMaster(centerMaster)
import XMonad.Layout.Accordion
import XMonad.Hooks.EwmhDesktops as EW
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spiral(spiral)
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle 
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed as R
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.ZoomRow
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Util.NamedScratchpad
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier as MGS
import XMonad.Layout.ShowWName
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies,copyToAll,wsContainingCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen ,nextWS , prevWS , toggleWS, toggleOrView)
import XMonad.Util.NamedActions
import XMonad.Util.Run (runProcessWithInput ,runInTerm, safeSpawn, spawnPipe)
import XMonad.Util.Cursor
import XMonad.Util.EZConfig (additionalKeysP)
import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import XMonad.Actions.Promote
import XMonad.Actions.ConditionalKeys
import Data.Char (isSpace)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M
import XMonad.Actions.CycleWS
import XMonad.Prompt.ConfirmPrompt    
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh
import XMonad.Actions.MouseResize
import XMonad.Prompt.XMonad
import Control.Arrow (first)
import XMonad.Util.SpawnOnce
import qualified XMonad.Actions.Search as S
import XMonad.Util.NamedActions
-- projects
import XMonad.Actions.DynamicProjects
import XMonad.Actions.SpawnOn
import Control.Monad ( join, when )
import Data.Maybe (maybeToList)
import XMonad.Util.Paste as P               -- testing
import XMonad.Actions.MessageFeedback


------------------------------------------------------------------------
--- mod key config 
------------------------------------------------------------------------

myModMask = mod4Mask
altMask = mod1Mask


------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
------------------------------------------------------------------------

main = do
  -- config file for xmobar is in .xmobarrc file 
  xmproc <- spawnPipe "xmobar"
  -- not in use 
  -- xmproc <- spawnPipe "taffybar"

  xmonad 
         $ dynamicProjects projects
         $ fullscreenSupport
         $ docks 
         $ ewmh
         $ myConfig xmproc


myConfig p = def
        { borderWidth        = myBorderWidth
        , clickJustFocuses   = myClickJustFocuses
        , focusFollowsMouse  = myFocusFollowsMouse
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , manageHook         = myManageHook <+> namedScratchpadManageHook scratchpads
        , handleEventHook    = myHandleEventHook
        , layoutHook         = myLayout
        , logHook            = myLogHook p
        , modMask            = myModMask
        , mouseBindings      = myMouseBindings
        , startupHook        = myStartupHook
        , terminal           = myTerminal
        , workspaces         = myWorkspaces
        }  `additionalKeysP` myKeys



------------------------------------------------------------------------
-- Applications 
------------------------------------------------------------------------

myTerminal :: String
myTerminal = "konsole"

github_chrome :: String
github_chrome = "google-chrome-stable --app=https://github.com/kiranbhanushali/planner?fullscreen=true"

myBrowser :: String
myBrowser = "google-chrome-stable"  
myBrowserClass = "google-chrome-stable"

myEditor :: String
myEditor = "vim" 

myFileManager:: String
myFileManager = "dolphin" 

-- preset keybindings.
myLauncher = "rofi -matching regex  -show combi -combi-modi window,run,drun"

-- give no. of windows in current workspace
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- SCRATCHPADS 
------------------------------------------------------------------------

scratchpads :: [NamedScratchpad]
scratchpads = 
    [ NS "term" "konsole -name sc" (resource =? "sc") (customFloating $ W.RationalRect 0 0.6 1 0.4),
      NS "xournalpp" "xournalpp" (className =? "Xournalpp") (customFloating $ W.RationalRect 0.1 0.1 0.8 0.8 ),
      NS "chrome" github_chrome (title =? "Problem Solving") largeRect
      -- NS "filemanager" "dolphin --new-window" (className =? "dolphin") (customFloating $ W.RationalRect 0 0 1 1 )
      -- NS "chrome" " " (className =? "gcscr") 
      --  (customFloating $ W.RationalRect 0.01 0.10 0.9 0.9)
    -- NS "browser" "chromium" (className =? "Chromium") (customFloating $ S.RationalRect (1/10) (1/20) (4/5) (9/10))
    -- , NS "TODO" "gvim --role TODO ~/TODO" (role =? "TODO") nonFloating
    ] where role = stringProperty "WM_WINDOW_ROLE"


-- Floating window sizes
largeRect = (customFloating $ W.RationalRect (1/20) (1/20) (9/10) (9/10))
smallRect = (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))


------------------------------------------------------------------------
-- Workspaces
------------------------------------------------------------------------

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

------------------------------------------------------------------------}}}
-- Workspaces                                                           {{{
---------------------------------------------------------------------------
wsAV    = "AV"
wsBSA   = "BSA"
wsCOM   = "COM"
wsDOM   = "DOM"
wsDMO   = "DMO"
wsFLOAT = "FLT"
wsGEN   = "GEN"
wsGCC   = "GCC"
wsMON   = "MON"
wsOSS   = "OSS"
wsRAD   = "RAD"
wsRW    = "RW"
wsSYS   = "SYS"
wsTMP   = "TMP"
wsVIX   = "VIX"
wsWRK   = "WRK"
wsWRK2  = "WRK:2"
wsGGC   = "GGC"
wsCP =  "CP"

-- myWorkspaces = map show [1..9]
myWorkspaces :: [String]

myWorkspaces = clickable . map xmobarEscape $ [wsGEN, wsWRK, wsWRK2, wsSYS, wsMON, wsFLOAT, wsRW, wsTMP]
            where
                 clickable l = [ "<action=xdotool key super+" ++ show (n) ++ " >" ++ ws ++ "</action> " |
                                 (i,ws) <- zip [1..9] l,
                                 let n = i ]

-- dont know what it is 
addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]


-- projects
projects :: [Project]
projects =

    [ Project   { projectName       = wsGEN
                , projectDirectory  = "~/"
                , projectStartHook  = Nothing
               -- , runInTerm "-name top" "htop"
                }
    , Project {
        projectName = wsCP
        ,projectDirectory ="~/Documents/cp/random"
        ,projectStartHook = Just $ do spawnOn wsWRK myTerminal
                                      spawnOn wsWRK myBrowser
                                      spawnOn wsWRK myFileManager
                                    
    }
    , Project   { projectName       = wsSYS
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawnOn wsSYS myTerminal
                                                spawnOn wsSYS myTerminal
                                                spawnOn wsSYS myTerminal
                }
{--

    , Project   { projectName       = wsDMO
                , projectDirectory  = "~/"
                -- , projectStartHook  = Just $ do spawn "/usr/lib/xscreensaver/binaryring"
                , projectStartHook  = Just $ do spawn "/usr/lib/xscreensaver/spheremonics"
                                                runInTerm "-name top" "top"
                                                runInTerm "-name top" "htop"
                                                runInTerm "-name glances" "glances"
                                                spawn "/usr/lib/xscreensaver/cubicgrid"
                                                spawn "/usr/lib/xscreensaver/surfaces"
                }
--}

    , Project   { projectName       = wsVIX
                , projectDirectory  = "~/.xmonad"
                , projectStartHook  = Just $ do spawn "konsole" 
                                                spawnOn wsVIX myTerminal
                                                spawnOn wsVIX myTerminal
                }

    , Project   { projectName       = wsMON
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawn "konsole"  
                }

    , Project   { projectName       = wsWRK
                , projectDirectory  = "~/wrk"
                , projectStartHook  = Just $ do spawnOn wsWRK myTerminal
                                                spawnOn wsWRK myBrowser
                }

    , Project   { projectName       = wsRAD
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawn myBrowser
                }

    , Project   { projectName       = wsTMP
                , projectDirectory  = "~/"
                -- , projectStartHook  = Just $ do spawn $ myBrowser ++ " https://mail.google.com/mail/u/0/#inbox/1599e6883149eeac"
                , projectStartHook  = Just $ do return ()
                }
    ]



------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.

-- myManageHook = composeAll
--     [
--      className =? "Gimp"                         --> doCenterFloat
--     , className =? "Mate-power-preferences"       --> doCenterFloat
--     , className =? "Xfce4-power-manager-settings" --> doCenterFloat
--     , className =? "FLTK" --> doFloat
--     , className =? "trilium notes" --> doFullFloat
--     , className =? "stalonetray"                  --> doIgnore
--     , className =? "mpv"                  --> doFullFloat 
--     , isFullscreen                                --> (doF W.focusDown <+> doFullFloat)
--     , isFullscreen                             --> doFullFloat
--     ,stringProperty "_NET_WMj_NAME" =? "Emulator" --> doFloat
--     ] <+> namedScratchpadManageHook scratchpads
myManageHook = composeAll . concat $
    [
      [ manageHook defaultConfig],
      [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFullFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
 --   , [(title =? x) --> moveTo Next | x <- my10Shifts]
    ] 
    where
    -- doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = ["kcalk", "feh" ,"breaktimer","mpv", "Xfce4-terminal"]
    myTFloats = ["Downloads",  "Save As...","Problem Solving"]
    myRFloats = []
    myIgnores = [""]
    -- my1Shifts = ["Chromium", "Vivaldi-stable", "Firefox"]
    -- my2Shifts = []
    -- my3Shifts = ["Inkscape"]
    -- my4Shifts = []
    -- my5Shifts = ["Gimp", "feh"]
    -- my6Shifts = ["vlc", "mpv"]
    -- my7Shifts = ["Virtualbox"]
    --my8Shifts = ["breaktimer"]
    -- my9Shifts = []
    my10Shifts = ["Problem Solving"]

------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.


mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True


outerGaps    = 8
myGaps       = gaps [(U, outerGaps), (R, outerGaps), (L, outerGaps), (D, outerGaps)]
addSpace     = renamed [CutWordsLeft 2] . spacing gap


-- Defining a bunch of layouts, many that I don't use.
tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing' 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing' 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full

floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)

threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 4
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme

myTabTheme = def { fontName            = myFont
                 , activeColor         = "#ECEFF4"
                 , inactiveColor       = "#4C566A"
                 , activeBorderColor   = "#5E81AC"
                 , inactiveBorderColor = "#2E3440"
                 , activeTextColor     = "#2E3440"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- The layout hook
myLayout = smartBorders $ avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
    $ mkToggle( single MIRROR)
    $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| grid
                                 |||  tabs
                                 ||| floats
                                 ||| noBorders monocle
                                 ||| magnify
                                 ||| threeCol
                                ||| Full
                                ||| zoomRow

-- layouts      = avoidStruts (
--                 tiled 
--                 ||| Mirror tiled
--                 -- ||| spiral (6/7) 
--                 ||| ThreeColMid 1 (3/100) (1/2) 
--                 ||| Full
--                 ||| fold
--                 ||| monocle
--              )
--                 where 
--                     tiled = Tall nmaster delta ratio
--                     fold = renamed [ R.Replace "Fold"] $Accordion
--                     monocle = renamed [Replace "monocle"] $ limitWindows 2 Full
--                     nmaster = 1
--                     ratio = 1/2 
--                     delta = 3/100

-- myLayout    = smartBorders
--               $ mkToggle( single MIRROR)
--               $ mkToggle (NOBORDERS ?? FULL ?? EOT)
--               $ layouts


------------------------------------------------------------------------
-- Colors and borders



base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
black   = "#dac400"
yellow  = "#b58900"
orange  = "#d9004c"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"

-- sizes
gap         = 10
topbar      = 10
myBorder    = 4
prompt      = 20
status      = 20

active      = orange
activeWarn  = "darkred"
inactive    = "silver"
focusColor  = orange
unfocusColor = base02

-- Color of current window title in xmobar.
xmobarTitleColor = activeWarn

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = activeWarn


xmobarInactiveColor = active
xmobarHiddenColor = inactive

-- border 

myBorderWidth = 5
myNormalBorderColor     =  active
myFocusedBorderColor    = focusColor


-- (TODO)
-- font 
myFont      = "xft:SF ProText Regular"
myBigFont   = "-*-montecarlo-medium-r-normal-*-11-*-*-*-*-*-*-*"
myWideFont  = "-*-montecarlo-medium-r-normal-*-11-*-*-*-*-*-*-*"
            ++ "style=Regular:pixelsize=180:hinting=true"


dtXPConfig :: XPConfig
dtXPConfig = def
      { font                = "xft:Mononoki Nerd Font:size=9"
      , bgColor             = "#292d3e"
      , fgColor             = "#d0d0d0"
      , bgHLight            = "#c792ea"
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , position            = Top
--    , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
      , height              = 20
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 100000  -- set Just 100000 for .1 sec
      , showCompletionOnTab = False
      , alwaysHighlight     = True
      , maxComplRows        = Nothing      -- set to Just 5 for 5 rows
      }


------------------------------------------------------------------------
--  Show Key bindings ( Not In Use and Not Working )

showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
    h <- spawnPipe "zenity --text-info --font=terminus"
    hPutStr h (unlines $ showKm x)
    hClose h
    return ()





------------------------------------------------------------------------
-- KEYBINDINGS
------------------------------------------------------------------------
-- I am using the Xmonad.Util.EZConfig module which allows keybindings
-- to be written in simpler, emacs-like format.



--[TODO] place to somewhere else
-- try sending one message, fallback if unreceived, then refresh
--
tryMsgR x y = sequence_ [(tryMessage_ x y), refresh]
myKeys :: [(String, X ())]
myKeys =
    -- Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")      -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")        -- Restarts xmonad
        , ("M-S-q", io exitSuccess)                  -- Quits xmonad

        --- brighness
        , ("<F3>" , spawn "xbacklight -inc 5")
        , ("<F2>" , spawn "xbacklight -dec 5")

        -- applications
        , ("M-<Return>", spawn myTerminal)
        , ("M-\\" ,  spawn myBrowser) -- browser
        , ("M-S-<Return>",  shellPrompt dtXPConfig)
        ,("M-p d", spawn myFileManager)

        --  Floating windows
        , ("M-f", sendMessage (T.Toggle "floats"))       -- Toggles my 'floats' layout
        -- , ("M-<Delete>", withFocused $ windows . W.sink) -- Push floating window back to tile
        , ("M-S-f", sinkAll)                      -- Push ALL floating windows to tile

    -- Increase/decrease spacing (gaps)
        , ("M-S-o", decScreenSpacing 4)         -- Decrease screen spacing
        , ("M-S-i", incScreenSpacing 4)         -- Increase screen spacing

-- Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Exoand vert window width

 -- Windows
        , ("M-<Backspace>", kill1)                           -- Kill the currently focused client
        , ("M-S-<Backspace>", killAll)                         -- Kill all windows on current workspace

-- zoom layout
  -- Increase the size occupied by the focused window
  , ("M-S-<KP_Add>", sendMessage zoomIn)
  -- Decrease the size occupied by the focused window
  , ("M-S-<KP_Subtract>", sendMessage zoomOut)
    -- Reset the size occupied by the focused window
  , ("M-S-<KP_Equal>", sendMessage zoomReset)

 -- Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , ("M-C-h", sendMessage $ pullGroup L)
        , ("M-C-l", sendMessage $ pullGroup R)
        , ("M-C-k", sendMessage $ pullGroup U)
        , ("M-C-j", sendMessage $ pullGroup D)
        , ("M-C-m", withFocused (sendMessage . MergeAll))
        , ("M-C-u", withFocused (sendMessage . UnMerge))
        , ("M-C-/", withFocused (sendMessage . UnMergeAll))
        , ("M-C-,", onGroup W.focusUp')    -- Switch focus to next tab
        , ("M-C-.", onGroup W.focusDown')  -- Switch focus to prev tab


        --- launcher
        , ("M-p p",  spawn myLauncher)
        , ("M-p q",  spawn "~/bin/dmenu/power.sh")
        , ("M-p k",  spawn "~/bin/dmenu/kill.sh")
        , ("M-p n",  spawn "~/bin/dmenu/wifi.sh")

        -- Scratchpads ( currently manage schractch pad using F1 key 
        -- , ("M-s-t", namedScratchpadAction scratchpads "term")
        -- , ("M-s-g", namedScratchpadAction scratchpads "chrome")
        -- , ("M-C-8", namedScratchpadAction scratchpads "settings")
        -- , ("M-s-d", namedScratchpadAction scratchpads "filemanager")
        -- , ("M-s-x", namedScratchpadAction scratchpads "xournalpp")

        -- Windows navigation
        , ("M-m", windows W.focusMaster)     -- Move focus to the master window
        , ("M-j", windows W.focusDown)       -- Move focus to the next window
        , ("M-k", windows W.focusUp)         -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster)    -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)      -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)        -- Swap focused window with prev window
        , ("M-;", promote)         -- Moves focused window to master, others maintain order
        , ("M1-S-<Tab>", rotSlavesDown)      -- Rotate all windows except master and keep focus in place
        , ("M1-C-<Tab>", rotAllDown)         -- Rotate all the windows in the current stack
        , ("M-S-d", windows copyToAll)
        , ("M-C-d", killAllOtherCopies)

        -- Fake fullscreen fullscreens into the window rect. The expand/shrink
        -- is a hack to make the full screen paint into the rect properly.
        -- The tryMsgR handles the BSP vs standard resizing functions.
        , ("C-<F11>" ,  sequence_ [ (P.sendKey P.noModMask xK_F11) , (tryMsgR (ExpandTowards L) (Shrink)), (tryMsgR (ExpandTowards R) (Expand)) ])  

        -- screenshot 
        ,("<Print>", spawn "scrot '%F-%T_$wx$h.png' -e 'mv $f ~/Pictures/ &&  xclip -selection clipboard -target image/png -i'")
        ,("M-S-<Print>", spawn "scrot -s '%F-%T_$wx$h.png' -e 'mv $f ~/Pictures/'")
        ,("M-S-`", spawn "xfce4-popup-clipman")

        -- Layouts
        , ("M-<Space>", sendMessage NextLayout)                -- Switch to next layout
        , ("M-C-M1-<Up>", sendMessage Arrange)
        , ("M-C-M1-<Down>", sendMessage DeArrange)

        , ("M-C-S-b", sendMessage ToggleStruts)     -- Toggles struts
        , ("M-b", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , ("M-S-b", sendMessage $ MT.Toggle NOBORDERS)      -- Toggles noborder

        , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))   -- Increase number of clients in master pane
        , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))  -- Decrease number of clients in master pane
        , ("M-S-<KP_Multiply>", increaseLimit)              -- Increase number of windows
        , ("M-S-<KP_Divide>", decreaseLimit)                -- Decrease number of windows

        , ("M-C-j", sendMessage MirrorShrink)               -- Shrink vert window width
        , ("M-C-k", sendMessage MirrorExpand)               -- Exoand vert window width

    -- Workspaces
        -- , ("M-.", nextScreen)  -- Swich focus to next monitor
        -- , ("M-,", prevScreen)  -- Switch focus to prev monitor
        -- , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        -- , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws

        , ("M-.", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        , ("M-,", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws
        , ("M-a" , toggleWS' ["NSP"])

        ,("M-w"  ,   switchProjectPrompt dtXPConfig)
        , ("M-S-w"  , shiftToProjectPrompt dtXPConfig)

        -- lock
        ,("M-C-S-l", spawn "sleep 1 && xtrlock")
        ]
        ++ [("<F1> " ++ k , f ) | ( k, f ) <- apps ]
           where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                 nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))
                 apps = [ 
                      ("g", namedScratchpadAction scratchpads "chrome")
                     , ("t", namedScratchpadAction scratchpads "term")
                     , ("n", namedScratchpadAction scratchpads "xournalpp")
                    -- , ( "f" , namedScratchpadAction scratchpads "filemanager")
                      ]





------------------------------------------------------------------------
-- Mouse bindings
------------------------------------------------------------------------


-- Focus rules

myClickJustFocuses :: Bool
myClickJustFocuses = True

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


-- mouse bindings 

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),       (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    -- switch to previous workspace
    , ((modMask, button4), (\_ -> prevWS))

    -- switch to next workspace
    , ((modMask, button5), (\_ -> nextWS))

  ]




------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.


myStartupHook = do
                setWMName "LG3D"
                -- have to create this file 
                --spawn     "bash ~/.xmonad/startup.sh"
               
                -- have to see documentation for this not working properly 
                -- imported from XMonad.utils.Cursors 
                -- setDefaultCursor xC_pirate

                -- this application are added on .xprofile file so here is no use 
                -- spawnOnce "stalonetray & "
                -- spawnOnce "klipper & "
                -- spawnOnce "volumeicon & "
                -- spawnOnce "redshift & "
                -- spawnOnce "xfce-power-manager-settings  & "
                -- spawnOnce "xfce-power-manager & "
                -- spawnOnce "kdeconnect-app & "



---------------------------------------------------------------------------
-- X Event Actions ( I dont know what it is )
---------------------------------------------------------------------------

-- for reference, the following line is the same as dynamicTitle myDynHook
-- <+> dynamicPropertyChange "WM_NAME" myDynHook

-- I'm not really into full screens without my say so... I often like to
-- fullscreen a window but keep it constrained to a window rect (e.g.
-- for videos, etc. without the UI chrome cluttering things up). I can
-- always do that and then full screen the subsequent window if I want.
-- THUS, to cut a long comment short, no fullscreenEventHook
-- <+> XMonad.Hooks.EwmhDesktops.fullscreenEventHook

myHandleEventHook = XMonad.Layout.Fullscreen.fullscreenEventHook




------------------------------------------------------------------------}}}
-- Log                                                                  {{{
---------------------------------------------------------------------------


myLogHook h = do

    -- following block for copy windows marking
    copies <- wsContainingCopies
    let check ws | ws `elem` copies =
                   pad . xmobarColor yellow red . wrap "*" " "  $ ws
                 | otherwise = pad ws

    ewmhDesktopsLogHook

    dynamicLogWithPP $ def
        { ppCurrent             = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
        , ppTitle               = xmobarColor xmobarTitleColor "" . shorten 50
        , ppUrgent              = xmobarColor "black"    "" . wrap " " " "

        , ppHidden = xmobarColor "black" "" . wrap "*" ""   -- Hidden workspaces in xmobar
        , ppHiddenNoWindows = xmobarColor "grey" ""   
        , ppSep =  "  "
        , ppWsSep               = " "
        , ppLayout              = xmobarColor "black" ""
        , ppOrder               = id
        , ppOutput              = hPutStrLn h  
        , ppSort                = fmap 
                                  (namedScratchpadFilterOutWorkspace.)
                                  (ppSort def)
                                  --(ppSort defaultPP)
        , ppExtras              = [windowCount] }


-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'super'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (m-od-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]

