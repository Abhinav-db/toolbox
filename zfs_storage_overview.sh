#!/bin/bash

### check all the ZFS pools and shares
### pass the admin hostname (or ip) for the ZFS you want to check

if [ "$#" -ne 1 ]
then
  echo "usage: $0 <zfs admin name>"
  exit 1
fi

ssh -T root@${1} <<EOF 
script  
  run('cd /')
  run('status');
  run('storage');
  pools = list(); 
  for (pool_i=0; pool_i < pools.length; pool_i++) {
    run('select ' + pools[pool_i]);
    pool_used = run('get used').split(/\s+/)[3];
    pool_avail = run('get avail').split(/\s+/)[3];
    pool_free = run('get free').split(/\s+/)[3];
    run('cd /')
    run('shares');
    run('set pool=' + pools[pool_i]);
    printf('POOL: %-40s\n', pools[pool_i]);
    printf('USED: %-10s\n', pool_used);
    printf('AVAIL: %-10s\n', pool_avail);
    printf('FREE: %-10s\n', pool_free);
    printf('    %-40s %-10s %-10s %-10s %-10s %-10s\n', 'SHARE', 'QUOTA', 'RESERVED','USED', 'AVAIL', 'SNAPUSED');  
    projects = list();  
    for (project_i = 0; project_i < projects.length; project_i++) {  
      run('select ' + projects[project_i]);  
      shares = list();  
      for (share_i = 0; share_i < shares.length; share_i++) {  
        run('select ' + shares[share_i]);  
        share = projects[project_i] + '/' + shares[share_i];
        total = run('get space_total').split(/\s+/)[3];  
        used = run('get space_data').split(/\s+/)[3];  
        avail = run('get space_available').split(/\s+/)[3];
        snap = run('get space_snapshots').split(/\s+/)[3];  
        quota = run('get quota').split(/\s+/)[3];  
        reservation = run('get reservation').split(/\s+/)[3];  
        printf('    %-40s %-10s %-10s %-10s %-10s %-10s\n', share, quota, reservation, used, avail, snap);  
        run('cd ..');  
      }  
      run('cd ..');  
    }
    printf('\n');
    run('cd /')
    run('status');
    run('storage');  
  }
  run('cd /');
.
exit
EOF

