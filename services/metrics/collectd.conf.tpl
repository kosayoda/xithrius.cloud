FQDNLookup false
Interval 10
Timeout 2
ReadThreads 5

LoadPlugin cpu
LoadPlugin df
LoadPlugin load
LoadPlugin memory
LoadPlugin disk
LoadPlugin interface
LoadPlugin uptime
LoadPlugin swap
LoadPlugin write_graphite
LoadPlugin processes
LoadPlugin aggregation
LoadPlugin match_regex

<Plugin df>
  # expose host's mounts into container using -v /:/host:ro  (location inside container does not matter much)
  # ignore rootfs; else, the root file-system would appear twice, causing
  # one of the updates to fail and spam the log
  FSType rootfs
  # ignore the usual virtual / temporary file-systems
  FSType sysfs
  FSType proc
  FSType devtmpfs
  FSType devpts
  FSType tmpfs
  FSType fusectl
  FSType cgroup
  FSType overlay
  FSType debugfs
  FSType pstore
  FSType securityfs
  FSType hugetlbfs
  FSType squashfs
  FSType mqueue
  MountPoint "/etc/resolv.conf"
  MountPoint "/etc/hostname"
  MountPoint "/etc/hosts"
  IgnoreSelected true
  ReportByDevice false
  ReportReserved true
  ReportInodes true
  ValuesAbsolute true
  ValuesPercentage true
  ReportInodes true
</Plugin>

<Plugin "disk">
  Disk "/^[hs]d[a-z]/"
  IgnoreSelected false
</Plugin>

<Plugin "aggregation">
  <Aggregation>
    Plugin "cpu"
    Type "cpu"
    GroupBy "Host"
    GroupBy "TypeInstance"
    CalculateAverage true
  </Aggregation>
</Plugin>

<Plugin interface>
  Interface "lo"
  Interface "/^veth.*/"
  Interface "/^docker.*/"
  IgnoreSelected true
</Plugin>

<Chain "PostCache">
  <Rule>
    <Match regex>
      Plugin "^cpu$"
      PluginInstance "^[0-9]+$"
    </Match>
    <Target write>
      Plugin "aggregation"
    </Target>
    Target stop
  </Rule>
  Target "write"
</Chain>

<Plugin "write_graphite">
 <Carbon>
   Host "localhost"
   Port 2003
   Prefix "collectd."
   EscapeCharacter "_"
   SeparateInstances true
   StoreRates true
   AlwaysAppendDS false
 </Carbon>
</Plugin>
