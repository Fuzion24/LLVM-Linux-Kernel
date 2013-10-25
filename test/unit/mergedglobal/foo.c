struct notifier_block
{
    int notifier_call
};
struct pernet_operations
{
    int init
};
static struct notifier_block rtnetlink_dev_notifier = {.notifier_call = 1 };

register_pernet_subsys (struct pernet_operations *);
register_netdevice_notifier (struct notifier_block *);
__attribute__ ((__section__ (".init.text"))) rtnetlink_net_init ()
{
}
static struct pernet_operations rtnetlink_net_ops = {.init =
        rtnetlink_net_init
};
rtnetlink_init ()
{
    register_pernet_subsys (&rtnetlink_net_ops);
    register_netdevice_notifier (&rtnetlink_dev_notifier);
}
