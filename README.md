# gym_app

A Flutter app designed for users who are members of busy gyms. Instead of set exercises broken into days (which leads to lots of waiting for machines), this app will track exercises that should be done given available gym equipment.

This means a list of all exercises will be the main tool available. Towards the top of the list will be exercises that are important (like compound lifts) and/or exercises that haven't been done recently. As exercises are completed, they're moved back towards the bottom, this way the user can make sure to hit all muscles.

## TODO

### In Progress
- [ ] Animate card movement on first page
  - opencontainer is making it hard to do the animation
- [ ] remove ignoring of deprecated libraries and try again (sharexfiles)
- [ ] Look into info messages in flutter analyze

### Completed
- [x] import/export exercise data. Just in case sharedprefs doesn't work. Also Android<->iOS before database
- [x] Save info between installs, bc I'm gonna be updating this app
    - It's not gonna be usable for me personally until then
    - did fragileuserdata, lets see how well it works
- [x] Count up stopwatch between sets
- [x] must click finish rest to close
- [x] .5 lb/kg doesn't work
- [x] when adding a new exercise add it to the top
- [x] back after search clears? (i actually don't remember when this was implemented)
- [x] Set notification sound at chosen time
- [x] After doing an exercise, move it to the bottom
- [x] Last set timer