env = require('test_run')
test_run = env.new()

SERVERS = { 'autobootstrap_guest1', 'autobootstrap_guest2', 'autobootstrap_guest3' }

--
-- Start servers
--
test_run:create_cluster(SERVERS)

--
-- Wait for full mesh
--
test_run:wait_fullmesh(SERVERS)

--
-- Print vclock
--
_ = test_run:cmd("switch autobootstrap_guest1")
box.info.vclock
_ = test_run:cmd("switch autobootstrap_guest2")
box.info.vclock
_ = test_run:cmd("switch autobootstrap_guest3")
box.info.vclock
_ = test_run:cmd("switch default")

--
-- Insert rows on each server
--
_ = test_run:cmd("switch autobootstrap_guest1")
_ = box.space.test:insert({box.info.server.id})
_ = test_run:cmd("switch autobootstrap_guest2")
_ = box.space.test:insert({box.info.server.id})
_ = test_run:cmd("switch autobootstrap_guest3")
_ = box.space.test:insert({box.info.server.id})
_ = test_run:cmd("switch default")

--
-- Synchronize
--

vclock = test_run:get_cluster_vclock(SERVERS)
test_run:wait_cluster_vclock(SERVERS, vclock)

--
-- Check result
--
_ = test_run:cmd("switch autobootstrap_guest1")
box.space.test:select()
_ = test_run:cmd("switch autobootstrap_guest2")
box.space.test:select()
_ = test_run:cmd("switch autobootstrap_guest3")
box.space.test:select()
_ = test_run:cmd("switch default")

--
-- Stop servers
--
test_run:drop_cluster(SERVERS)
