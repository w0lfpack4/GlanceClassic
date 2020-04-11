# Glance Information Bar (Classic)

## Folder Structure
./Addon holds the addon folders to use in WoW. 

## About Glance

Glance is a modular information bar with many modules provided by default.  Glance has been built from the bottom up to allow developers to create their own data brokers.  Each module can be enabled or disabled via the user interface, or the Glance Interface Options panel.  So use what you like, turn off what you don't, and let me know what else you'd like to see.  I encourage you to read through this somewhat lengthy description, to see just what Glance is capable of.


## Glance Features

* Modules can send information to themselves about other party members who are also using Glance. This behavior can be turned off.
* Modules can be re-positioned by dragging them left or right one position at a time.
* Modules can be enabled or disabled in the Options panel.
* Hover over a module in the options panel to see notes, updates, and memory usage.
* Click the gear icon, or type **/glance options** to access the Options Panel.
* Shifts the Player, Target, Buff, and Minimap frames down a touch to make room for itself. This behavior can be turned off for each frame.
* Shows time played in the chat window. This behavior can be turned off.
* Use the font Glance comes with, or change to another game font.
* Glance will turn red while you are in combat.
* Glance will turn blue while you are resting.
* Click on the color swatches to change the color and transparency of the bar, bar in combat, bar resting, and bar border.
* Cursor will highlight when over a button.
* Use the slider scale in the Options panel to make the bar larger or smaller.
* Option to scale tooltips with the bar.
* Modules are all listed together on the WoW addon screen.
* Settings can be saved to and loaded from a global profile.
* Dock Glance at the top or bottom of the screen.
* Option to Auto-Hide the bar until mouseover.

## Glance Modules

###  Armor

* Bar displays the durability of your armor as a percent.
* Color will change from green to yellow to red as you take damage.
* Tooltip displays the total cost to repair your armor.
* Tooltip displays your average item levels and missing gear.
* Module will auto-repair your armor at a merchant with guild funds if available, or your own funds if not.  Right click to change this behavior.
* Module will add text overlays on the character frame and inspect frame to display the item level of each piece of gear. Right click to change this behavior.
* Module will display item level and missing items in the tooltip of any player you click on. Right click to change this behavior.

###  Bags

* Displays Used/Total, Free/Total, Free, Used, and Total bag space.
* Option to count or not count profession bags.
* Left click to toggle bags.

###  Clock

* Bar displays Server time (s), Local time (l), or Date.  Right click to change.
* Tooltip displays Server time, Local time, and Date.
* Time options for 12h or 24h.
* Left click to open the calendar.

###  Framerate

* Bar displays current frames per second (FPS)
* Tooltip displays current framerate, as well as minimum, maximum, and average for the current session.
* Tooltip displays party stats for average framerate per party member.

###  Friends

* Bar displays Friends/RealID Friends that are currently online.
* Tooltip displays friends.  Name, color coded by class, and location.
* Left click to open the Friends tab.
* Module will display Battle.net friends even if they are playing another game.

###  Gold 

* Bar displays either total gold, character's gold, or gold per hour.  Right click to change.
* Tooltip displays gold per account, per faction, per character with totals on a given realm.
* Tooltip displays gold per sesion, and gold per hour.
* Right click to delete an old character or faction.

###  Guild

* Bar displays guild members that are currently online.
* Tooltip displays guild members. Name, class, level, color coded by class, and location.
* Left click to open the Guild tab.

###  Latency

* Bar displays current latency (Lag) home/world in milliseconds.
* Tooltip displays current home and world latency and bandwidth used.
* Tooltip displays party stats for home/world latency per party member.

###  Location

* Bar displays current zone and subzone and current map coordinates.
* Bar will now display a player's current speed.
* Any of the display elements can be toggled off.

###  Memory

* Bar displays current addon memory usage in megabytes or percentages.
* Bar displays current addon CPU usage in seconds used or percentages.
* Tooltip displays each addon and how much memory/cpu it is using in real-time.
* Tooltip displays arrows to show current activity (increase or decrease).
* Left click to recycle memory.  This is data left in memory that is no longer used.
* Module can force memory recycling on login.  Right click to change this behavior.
* Shift left click to launch ACP if it is installed. (Optional Dependency)
* All modules of an addon are shown as one line item of combined memory.  Right click to change this behavior and display the memory usage of each module.
* Track addons loaded on demand

###  Professions

* Bar displays currently tracked profession (current/total points).
* Bar displays orange warnings when new skill levels are available at the trainer.
* Bar and Tooltip display bonus points for racial traits, equipment, lures, etc.
* Tooltip displays professions, level, and current skill points.
* Tooltip displays best gathering locations and types based on your skill level.
* Left click to open the Professions tab.  
* Right click to select which profession to display on the bar.

###  Reputation

* Bar displays either a percentage earned or points remaining for the currently tracked reputation.  Right click to change the display.
* Tooltip displays the currently tracked repution.
* Tooltip displays percent earned and points remaining on the currently tracked reputation.
* Left click to open the Reputation tab.
* Right click to select a reputation to track.
* Tracks multiple reputations

###  XP

* Bar displays your current experience (XP) as a percent and your level.
* Text color matches resting state. Blue for using rested xp, purple when not rested.
* Tooltip displays the total xp for your current level, how much xp you have gained, how much you need, and your rested xp.
* Tooltip displays the time played on this character, this level, and this session.
* Tooltip displays your leveling speed in xp per hour and how long it will take you to level.
* Tooltip displays an average number of kills, quests, and gathers you need to level.
* Tooltip displays a hunters pet level and xp.
* Tooltip displays party stats for level, xp, and xp per hour per party member.
	
## Glance Slash Commands

* **/glance hide**
Hides the Glance bar.

* **/glance show**
Shows the glance bar.

* **/glance options**
Shows the Glance Interface Options panel.

## Developers

* Feel free to develop modules of your own for Glance.