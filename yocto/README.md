### Build Instructions (macOS)

1. Install dependencies

        brew install go vagrant virtualbox ansible
        vagrant plugin install vagrant-disksize

2. Run Vagarnt Box and SSH into it

        # Check Vagrantfile to confirm CPU/memory allocation is suitable then run:
        vagarnt up
        vagrant ssh

3. Setup SSH key for Bitbucket in your Vagrant Box

        ssh-keygen
        cat ~/.ssh/id_rsa.pub
        # copy contents of ~/.ssh/id_rsa.pub and add it to your Bitbucket account
        # test git connection:
        ssh -T git@bitbucket.org

4. Build using Bitbake

        cd app
        source poky/oe-init-build-env build-rpi3
        bitbake core-image-base

5. Once completed, the images will in this folder `~/yocto-tmp/deploy/images/raspberrypi4-64`, for example: `~/yocto-tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.sdimg` will be the full SD image.


### Flashing Instructions
1. It's recommended to install bmap tool for more efficient flashing:

        curl -Lo bmaptool  https://github.com/01org/bmap-tools/releases/download/v3.4/bmaptool && chmod +x bmaptool && mv bmaptool /usr/local/bin/bmaptool

2. Copy the artifacts from Vagrant to host machine:

        cp ~/yocto-tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.sdimg ~/app/
        cp ~/yocto-tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.sdimg.bmap ~/app/


3. Flash on the host machine

        diskutil list # Find target device (lsblk for Liux)
        sudo bmaptool copy ./core-image-base-raspberrypi4-64.sdimg /dev/rdisk2 # for macOS, prepend r to device file, for example /dev/disk2 -> /dev/rdisk2
