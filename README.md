# Darwin Runtime Monitor

Monitor information from system tooling and alert upon reaching configurable threshold levels

> This tool is not affiliated with or endorsed by Apple

## Screenshots

**Medium Swap usage alerts**

<p align="left">
  <img width="256" src="media/swap-warning.png" alt="Example image removed">
</p>

**Increased Kernel CPU usage**

<p align="left">
  <img width="256" src="media/kernel-cpu-warning.png" alt="Example image removed">
</p>

## Structure

This tool consists of three parts 

1. Scitps that query, process and alert, eg. [swapusage.sh](./swapusage.sh) or [kernelcpu.sh](./kernelcpu.sh)
2. Main script that aggregates all other processor scripts (1), ie. [runtime_monitor.sh](./runtime_monitor.sh)
3. Scheduler manifest that is linked to the standard Launchd location and executes the main script (2) at defined intervals - [com.darwinruntime.monitor.plist](./com.darwinruntime.monitor.plist)

## Installation

**Download**
```bash
curl -LO https://github.com/spekulant/darwin-runtime-monitor/releases/download/latest/darwin-runtime-monitor.zip
curl -LO https://github.com/spekulant/darwin-runtime-monitor/releases/download/latest/darwin-runtime-monitor.zip.sha256
```

**Verify the integrity of the package**
```bash
shasum -a 256 -c darwin-runtime-monitor.zip.sha256
```

**Install the package**

```bash
unzip darwin-runtime-monitor.zip
cd darwin-runtime-monitor
./install.sh
```

> the `install.sh` script will overwrite any previous version in `~/.runtime-monitor` and so will also be the same script you can use to upgrade to a new version.

## Uninstall

Just run `./uninstall.sh`

## Monitored values

**SWAP usage**

This script makes use of `sysctl` to extract information about current SWAP usage. 

Too high levels of SWAP usage indicate the system ran out of memory and started allocating 
information on your disk - which is several times slower than RAM. This usually leads to system slowness.

When the script notices there is `x >= 512MB` of SWAP allocated, it sends the first notification saying the SWAP usage is rising and that you might consider closing some apps.

<p align="left">
  <img width="256" src="media/swap-warning.png" alt="Example image removed">
</p>

At the level of `x >= 1000MB` it sends a notification alert saying the usage is high. You'd most probably feel the system to be sluggish at this point anyway, and this notification will just help you pinpoint the issue and take action before even more memory is commited to SWAP.

**Kernel CPU usage**

High Kernel CPU usage should be quite unusual and indicates an issue that may have to be remediated as a priority. In this state, the kernel starves other processes and leads to general system slowness.

When the Kernel CPU usage reaches ~40%, the tool issues the first notification saying the Kernel CPU usage is increasing

<p align="left">
  <img width="256" src="media/kernel-cpu-warning.png" alt="Example image removed">
</p>

This can be down to various reasons, one that I encounter relatively often is USB-C adapters. Sometimes it's enough to just plug the adapter into a different port, sometimes switching it to the other side works. If nothing helps, it may just be a case of plain incompatibility. 

## Parameters

- `~/.runtime-agent/swapusage.sh`: `MEDIUM_THRESHOLD` = `512` ( MB )
- `~/.runtime-agent/swapusage.sh`: `HIGH_THRESHOLD` = `1000` ( MB )
- `~/.runtime-agent/kernelcpu.sh`: `MEDIUM_THRESHOLD` = `40` ( %CPU )
- `~/.runtime-agent/kernelcpu.sh`: `HIGH_THRESHOLD` = `100` ( %CPU )
- `~/.runtime-agent/com.darwinruntime.monitor.plist`: `StartInterval` = `900` ( every 15 mins )

## Troubleshooting

1. Try running the main script manually. It is expected it should take a few seconds to run - if it exits immediately, the issue would be somewhere downstream. 

```bash
~/.runtime-monitor/runtime_monitor.sh
```

If it exits after ~3 seconds without any errors, then the issue may be upstream - in the Launchagent configuration: 

2. Try running the launchd process manually

```bash
launchctl start com.darwinruntime.monitor
```

You can see the status of the task with `launchctl list | grep darwinruntime`

> `-	78	com.darwinruntime.monitor`

The number is the exit code the task returned, so anything other than 0 is some kind of error

You can inspect the error code with `launchctl error <code>`

```bash
$ launchctl error 78
> `78: Function not implemented`
```

You can also lookup the logs to try and find something relevant

```bash
grep darwinruntime /var/log/com.apple.xpc.launchd/launchd.log
```

It may take some digging but eventually something readable should surface

> Service could not initialize: access(/Users/tomaszsobota/runtime-monitor/runtime_monitor.sh, X_OK) failed with errno 2 - No such file or directory, error 0x6f - **Invalid or missing Program/ProgramArguments**

While at it, we can also lint the `plist` file to be 100% sure this is not due to any obvious errors

```bash
$ plutil -lint com.darwinruntime.monitor.plist
> com.darwinruntime.monitor.plist: OK
```

This particular issue was fixed by swapping the ProgramArguments with a simplified Program definition, then we have to boot out the current failed execution and load the new one again:

```
launchctl unload ~/Library/LaunchAgents/com.darwinruntime.monitor.plist
launchctl load ~/Library/LaunchAgents/com.darwinruntime.monitor.plist
```

## License

[Creative Commons - Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/) as per the [LICENSE](./LICENSE) file
