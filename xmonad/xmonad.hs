
--
--- Clickable workspaces depend on xdotool
--

--Begin imports
import XMonad
import XMonad.Actions.CycleWS (prevWS, nextWS)
--import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
--import XMonad.Hooks.UrgencyHook
import XMonad.Layout.LayoutHints
--import XMonad.Layout.Tabbed
--import XMonad.Layout.Grid
--import XMonad.Layout.IM
--import XMonad.Layout.Reflect
import XMonad.Layout.NoBorders
import System.IO

import Data.Monoid
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import System.Exit
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import Data.List
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.ResizableTile
import XMonad.Layout.Named
import XMonad.Layout.Tabbed
import XMonad.Layout.Grid



bar = "dzen2 -fg '#ffffff' -bg '#000000' -fn '-*-clean-*-*-*-*-*-*-*-*-*-*-*-*' -ta  l -x 0 -y 0 -h 18 -w 700"

main = do
  xmproc <- spawnPipe bar
  xmonad $  defaultConfig
    {
      manageHook        = manageDocks <+> myManageHook <+> manageHook defaultConfig,
      layoutHook        = smartBorders $ avoidStruts $ layoutHook defaultConfig,
      ---layoutHook     = smartBorders $ avoidStruts $ tiled ||| Mirror tiled ||| Full ||| Grid ||| Tall,
      logHook           = myLogHook xmproc,
      --modMask         = mod4Mask,
      workspaces        = myWorkspaces,
      terminal          = "Terminal",
      borderWidth       = 1,
      normalBorderColor = "#222222",
      focusedBorderColor  = "#7659ab"
    }

      `removeKeys`
    [
      ((shiftMask .|. mod1Mask, xK_Return))
    , ((mod1Mask, xK_p))
    ]

      `additionalKeys`
    [
      ((mod1Mask, xK_Return), spawn "Terminal")
    , ((mod1Mask, xK_m ), spawn "exe=`dmenu_path | dmenu -fn '-*-clean-medium-r-*-*-12-*-*-*-*-*-*-*'  -nb '#1c1c1c' -nf '#98a1b9' -sb '#888888' -sf '#ffffff'` && eval \"exec $exe\"")
    , ((mod1Mask, xK_f), (windows $ W.greedyView "web") >> spawn "firefox")
    ]

myLogHook :: Handle -> X()
myLogHook h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }

customPP :: PP
customPP = defaultPP
  {
    ppHidden    = wrap "^fg(#8f8f8f)^p(2)^i(/home/daniel/.xmonad/icons/has_win.xbm)" "^p(2)^fg()^bg()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId,
    ppCurrent   = wrap "^fg(#ffffff)^p(2)^i(/home/daniel/.xmonad/icons/plus.xbm)" "^p(2)^fg()^bg()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId,
    ppTitle     = dzenColor "#98a1b9" "" . shorten 50,
    ppUrgent    = dzenColor "#ff0000" "" . wrap "*" "*",
    ppSep       = " ",
    ppLayout    = dzenColor "#f1f1f1" "" .
                (\x -> case x of
                  "Tall"        -> "Tall ^i(/home/daniel/.xmonad/icons/tall.xbm)"
                  "Mirror Tall" -> "Mirror ^i(/home/daniel/.xmonad/icons/mtall.xbm)"
                  "Full"        -> "Full ^i(/home/daniel/.xmonad/icons/full.xbm)"
                ),
    ppVisible         = dzenColor "#8f8f8f" "" . wrap "[" "]",
    ppHiddenNoWindows = wrap "^fg(#8f8f8f)^p(2)^i(/home/daniel/.xmonad/icons/has_win_nv.xbm)" "^p(2)^fg()^bg()" . \wsId -> if (':' `elem` wsId) then drop 2 wsId else wsId
  }

--
--Hooks
--
myManageHook = composeAll
  [
    className =?  "Namoroka"  --> doShift "web",
    className =?  "Pidgin"    --> doFloat,
    className =?  "gimp"      --> doFloat,
    className =?  "Nautilus"  --> doFloat,
    className =?  "vlc"       --> doShift "media"
  ]

--
--Workspaces
--
--myWorkspaces  = ["term", "web", "media", "down", "chat", "else"]

myWorkspaces  ::  [String]
myWorkspaces  = clickable . (map dzenEscape) $ ["term", "web", "media", "down", "chat", "else"]

  where clickable l = [ "^ca(1,xdotool key alt+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
    (i,ws) <- zip [1..] l,
    let n = i ]


