# ravenfall-multichat-client
Frontend for [ravenfall-multichat-server](https://github.com/abrokecube/ravenfall-multichat-server)

<img width="852" height="519" alt="20260130062311_ravenfall-chatting console" src="https://github.com/user-attachments/assets/8cf06d48-7d70-4b50-a664-7db5ba406a34" />

Developed with Godot 4.4  

- See [ravenfall-multichat-server](https://github.com/abrokecube/ravenfall-multichat-server) on how to add accounts  
- Join twitch channels by typing `/join <channel name>` in the chat box
- The client tracks when you use `!join` to determine where a character is.
- Left click on a character plate to autofill the user and channel inputs. Right click to only fill the user input
- Left click on a channel to autofill the channel input. Right click to filter characters by channel
- To change the server address, Open settings (`Se.` button on the bottom right), type in a new network address and click apply.
- Click on the Se. button again to close settings.

### Character plate background colors
In order of least to most priority -- if a character 'needs saliing' and is 'fully rested', then the 'fully rested' color will appear, overriding 'needs sailing'
| Color | Description |
|-------|------------|
| Black/None | Character is okay |
| Red   | Not earning exp |
| Dark green | Current skill is maxed out |
| Orange | Needs to be sailed to another island |
| Light blue | Character is fully rested |

Contributions to make this less jank and more user friendly are welcome
