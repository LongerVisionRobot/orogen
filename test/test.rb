require 'orogen_ros/test'

require 'orocos'

describe Orocos::ROS::Generation::Project do
    include Orocos::ROS::SelfTest

    Orocos::ROS.spec_search_directories << File.join(File.dirname(__FILE__),"orogen")

    describe "loading ROS files" do
        Orocos::ROS.load(File.join(File.dirname(__FILE__),"orogen"))

        launchers = Orocos::ROS.available_launchers
        assert !launchers.empty?, "Launchers empty"
        puts "Available launchers"
        launchers.each do |l|
            puts "Launcher: #{l} #{l.class}"
        end
    end

    describe "loading orogen specs with ros definition" do
        Orocos::ROS.spec_search_directories.each do |dir|
            specs = Dir.glob(File.join(dir,"*.orogen"))
            specs.each do |file|
                p = Orocos::ROS::Generation::Project.load(file)

                assert !p.orogen_project?

                p.self_tasks.each do |t|
                    puts "Task: #{t} --> #{t.ros_name}"
                end

                if !p.ros_launchers.empty?
                    launcher = p.ros_launchers[0]
                    assert_equal "test", launcher.name
                end
            end
        end # Orocos::ROS.spec_search_directories
    end # describe

    describe "loading launcher definition" do
        specs = Dir.glob(File.join(File.dirname(__FILE__),"orogen","manipulator_config.orogen"))
        specs.each do |file|
            p = Orocos::ROS::Generation::Project.load(file)

            assert !p.orogen_project?

            p.self_tasks.each do |t|
                puts "Task: #{t} --> #{t.ros_name}"
            end

            assert !p.ros_launchers.empty?
            launcher = p.ros_launchers[0]
            assert_equal "test", launcher.name
            puts launcher
            assert !launcher.nodes.empty?, "Launcher did not contain nodes"
            launcher.nodes.each do |n|
                puts "Node #{n} #{n.task_model}"
            end
        end
    end # describe 

    describe "rosnode_findpackage" do
        Orocos::ROS.load

        package = Orocos::ROS.rosnode_findpackage("state_publisher")
        assert package.name == "artemis_state_publisher", "Find package of node #{package}"
    end

    describe "simple functions" do
        assert_equal "/test", Orocos::ROS.rosnode_normalize_name("test"), "Node name normalization"
        assert_equal "/test", Orocos::ROS.rosnode_normalize_name("//test"), "Node name normalization"
        assert_equal "/test", Orocos::ROS.normalize_topic_name("////test"), "Topic name normalization"
        assert_equal "/test", Orocos::ROS.normalize_topic_name("test"), "Topic name normalization"
    end

    describe "equality" do
        n1 = Orocos::ROS::Spec::Node.new(nil, "test")
        n2 = Orocos::ROS::Spec::Node.new(nil, "test")

        assert_equal n1,n1, "Node equality"
        assert_equal n1,n2, "Node equality"
    end

    describe "node superclass" do
        n1 = Orocos::ROS::Spec::Node.new(nil, "test")
        assert_equal n1.superclass.name, "ROS::Node", "Node superclass should be ROS::Node, but was #{n1.superclass.name}"
    end

    describe "node spec" do

        assert Orocos::ROS.node_spec_available?("artemis_motionPlanner"), "Node spec available"

        spec = Orocos::ROS.node_spec_by_node_name("artemis_motionPlanner")
        assert spec.has_port?("status")
        assert spec.has_port?("target_trajectory")

        assert spec.find_output_port("status")
    end
end

