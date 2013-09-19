#!/usr/bin/env ruby

# while [[ $( ./sdk/platform-tools/adb remount ); $? != 0 ]]
# do
#   sleep 1
#   echo "Snoozing"
# done

SDK_PATH = "#{ENV['HOME']}/Dropbox/android_sdk/adt-bundle-mac-x86_64-20130729/sdk"

platform_tools = "platform-tools"
tools = "tools"

adb = File.join(platform_tools, "adb")
emulator = File.join(tools, "emulator")
Dir.chdir(SDK_PATH) do
  warn `pwd`

  unless system("./#{adb} remount")
    system "./#{emulator} -avd galaxy_nexus -partition-size 512 &"
  end

  while ( !system(%w[./adb remount] ) )
    sleep 5
    warn "Sleeping... waiting for adb remount"
  end

  system "#{adb} push /etc/hosts /system/etc"

end
