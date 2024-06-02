# 0.0.1
* Fixed bug where timeout from a previous game cleans up a current game
* Fixed a bug where a player placed a hideblock not as part of a game, and then missing metadata when it is dug
* Fixed bug where clutter blocks fall through the floor as it is cleaned up
* Fixed a potential infinite loop bug when there's no valid place to put the hiding block
* Documented code and moved this around a bit