include_recipe "ssh"

case node[:platform]
when "debian", "ubuntu"
  package "gitosis"

  user "gitosis" do
    action :remove
  end
  group "gitosis" do
    group_name "gitosis"
    action :remove
  end
  directory "/srv/gitosis" do
    recursive true
    action :delete
  end

  user 'git' do
    shell "/bin/sh"
    comment "git version control"
    # TODO : set git home as attribute
    home "/srv/git"
    system true
    supports  :manage_home => true
    action :create
  end
  # TODO : set git home as attribute
  directory "/srv/git" do
    owner "git"
    group "git"
    mode 0750
  end
else 
  package "dev-vcs/gitosis"
end

git_admin = search(:users, "git_is_admin:true").first

execute "gitosis-init" do
  command "sudo -H -u git gitosis-init < /home/#{git_admin['id']}/.ssh/id_rsa.pub"
  # TODO : set git home as attribute
  not_if "test -d /srv/git/gitosis"
end

# TODO: add other users from data bag with set value "git_has_access:true" to gitosis repository