## Jboss eap 7 Snapshot


```
/opt/jboss-eap/bin/jboss-cli.sh --connect
```
**Take a Snapshot**
```
:take-snapshot
```
**List Snapshots**
```
:list-snapshots
```
**Delete Snapshots**
```
 :delete-snapshot(name=20200501-133140009standalone.xml)
```
**Test snapshot file**
```
/opt/jboss-eap/bin/standalone.sh --server-config=standalone_xml_history/snapshot/20200501-133140009standalone.xml
```