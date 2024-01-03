# Setup

## Hardware

- Raspberry Pi 4
- ESP32 dev boards: https://www.amazon.com/dp/B09DPH1KXF
- Smart plugs: https://cloudfree.shop/product/cloudfree-smart-plug-runs-tasmota/
- 3D printer: https://www.amazon.com/gp/product/B073ZLSMFT/
- IR transmitter diodes: https://www.amazon.com/HiLetgo-Infrared-Emitter-Receiver-Emission/dp/B00M1PN5TK

Local Pi address: 192.168.1.13
Local Home Assistant address: 192.168.1.13:8123
Local Octoprint address: 192.168.1.13:5000

## On laptop

- Install ESPHome (`brew install esphome`): https://esphome.io/guides/installing_esphome.html
- `cp esphome/template_secrets.yaml esphome/secrets.yaml`
- Add valid values for `esphome/secrets.yaml`

## On router

Statically reserve 192.168.1.13 for the Pi.

## On raspberry pi

- Follow `setup.sh` (not totally scripted, copy/paste the lines to make sure they succeed)
- Set up the printer settings
  - https://www.reddit.com/r/MPSelectMiniOwners/comments/6ky6jj/octoprint_setup/
  - https://plugins.octoprint.org/plugins/malyan_connection_fix/
  - Use custom bounding box of -1 for X axis

## Adding a new smart plug

- Connect to the tasmota wifi. If the tasmota wifi isn't appearing:
  - It's possible the specific power outlet isn't playing well with the plug, for whatever reason. Try another outlet.
  - It's possible the plug was already configured to the home network. Visit http://192.168.1.1/ and look among "Attached Devices" for devices similar to TASMOTA-XXX-YYY.
- Provide the home network wifi credentials
  - Not the extension home network, just the base name
  - If you provide the wrong network, you can reset the device by turning it on/off 7 times: https://tasmota.github.io/docs/Device-Recovery/#fast-power-cycle-device-recovery
- Provide a new hostname (Configuration > Configure Other > Device Name + Friendly Name)
- Provide the 192.168.1.13 host to the MQTT Tasmota settings (Configuration > Configure MQTT)
  - Port is 1883
- Add toggle in Home Assistant

## Adding a new IR command

- Hook up the base of NPN transistor to pin 22, with the transistor in series with an IR LED and a 330 ohm resistor.
- Hook up an IR receiver module to pin 22, 3.3V and GND.
- `cd esphome`
- `esphome run remotecontrol.yaml`
- Watch the serial output and record the values in `remotecontrol.yaml` under a new button
- Run `esphome run remotecontrol.yaml` again to deploy the changes
