# Paperless-ngx-Sensor

# Scope

This is a Luup plugin to keep an eye on your Paperless-ngx instance - https://github.com/paperless-ngx/paperless-ngx

Luup (Lua-UPnP) is a software engine which incorporates Lua, a popular scripting language, and UPnP, the industry standard way to control devices. Luup is the basis of a number of home automation controllers e.g. Micasaverde Vera, Vera Home Control, OpenLuup.

# Compatibility

This plug-in has been tested on the Ezlo Vera Home Control system.
You need a Paperless-ngx instance running which you can access 

# Features

It supports the following functionality:

* Creation of a device in the UI to show your Paperless-ngx configuration
* Periodically updates the number of documents etc 

Still to be added..

* Add a button to refresh labels on demand
* Add default variable to show other system label information
* other fixes/updates

# Imstallation / Usage

This installation assumes you are running the latest version of Vera software.

1. Upload the icon documents.png file to the appropriate storage location on your controller. For Vera that's `/www/cmh/skins/default/icons`
2. Upload the .xml and .json file in the repository to the appropriate storage location on your controller. For Vera that's via Apps/Develop Apps/Luup files/
3. Create the decice instance via the appropriate route. For Vera that's Apps/Develop Apps/Create Device/ and putting "D_xxxxxxxxx.xml" into the Upnp Device Filename box. 
4. Reload luup to establish the device and then reload luup again (just to be sure) and you should be good to go.

# Quick Configuration script

After you have added the files and created the device, the following is a quick way to configure the device, simply update the following and run it via Apps/Develop Apps/Test Code 

````
local DEVICE = 1210
local SERV = "urn:nodecentral-net:serviceId:Paperless1"
local Username = "yourusername"
local Password = "yourpassword"
local IpPort = "192.168.1.234:8777"
luup.variable_set(SERV, "Username", Username, DEVICE)
luup.variable_set(SERV, "Password", Password, DEVICE)
luup.variable_set(SERV, "IpPort", IpPort, DEVICE)
luup.reload()
````

# Limitations

While it has been tested, it has not been tested very much and may not support other related devices or those running different firmware.

# Buy me a coffee

If you choose to use/customise or just like this plug-in, feel free to say thanks with a coffee or two.. 
(God knows I drank enough working on this :-)) 

<a href="https://www.paypal.me/nodezero" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

# Screenshots

Once installed, you should see the device listed with your display label

![0B09F54D-8C1C-4CFD-9C16-65CC0FFD1A27](https://user-images.githubusercontent.com/4349292/204249001-01f6e506-4019-4ced-b200-5a185741dc82.jpeg)


# License

Copyright © 2022 Chris Parker (nodecentral)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses
