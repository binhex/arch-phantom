**Application**

[Phantom](https://github.com/jhead/phantom)

**Description**

Makes hosted Bedrock/MCPE servers show up as LAN servers, specifically for consoles. You can now play on remote servers (not Realms!) on your Xbox and PS4 with friends. It's like having a LAN server that's not actually there, spooky.

**Build notes**

Latest GitHub release of Phantom.

**Usage**
```
docker run -d \
    -p 19132:19132 \ 
    --name=<container name> \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e MINECRAFT_SERVER=<ip of remote minecraft server:port number>
    -e CLEANUP_TIMEOUT=<cleanup timeout in second>
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-phantom
```
Please replace all user variables in the above command defined by <> with the correct values.

**Example**
```
docker run -d \
    -p 19132:19132 \ 
    --name=phantom \
    -v /apps/docker/phantom:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e MINECRAFT_SERVER=1.2.3.4:19132
    -e CLEANUP_TIMEOUT=60
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-phantom
```

**Notes**

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

```
id <username>
```
___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](http://lime-technology.com/forum/index.php?topic=45837.0)