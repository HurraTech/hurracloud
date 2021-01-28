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
