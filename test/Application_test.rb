# -*- coding: utf-8 -*-

require 'oktest'
require 'skeema'
require 'stringio'


class Dummy

  def stdout
    bkup = $stdout
    $stdout = stdout = StringIO.new
    begin
      yield
    ensure
      $stdout = bkup
    end
    stdout.rewind
    return stdout.read()
  end

  def stderr
    bkup = $stderr
    $stderr = stderr = StringIO.new
    begin
      yield
    ensure
      $stderr = bkup
    end
    stderr.rewind
    return stderr.read()
  end

  def stdouterr
    bkup = [$stdout, $stderr]
    $stdout = stdout = StringIO.new
    $stderr = stderr = StringIO.new
    begin
      yield
    ensure
      $stdout, $stderr = bkup
    end
    stdout.rewind
    stderr.rewind
    return [stdout.read(), stderr.read()]
  end

end


Oktest.scope do


  topic Skeema::Application do

    klass = Skeema::Application


    topic '.run()' do

      fixture :app do
        Skeema::Application.new
      end

      spec "[!ktlay] prints help message and exit when '-h' or '--help' specified." do |app|
        [
          ["-h", "foo"],
          ["--help", "foo"],
        ].each do |args|
          sout, serr = Dummy.new.stdouterr do
            status = app.run(args)
            ok {status} == 0
            ok {args} == ["foo"]
          end
          expected = <<END
Usage: #{File.basename($0)} [common-options] action [options] [...]
  -h, --help          : show help
  -v, --version       : show version

Actions:
  help [action]       : show help message of action, or list action names
END
          ok {sout} == expected
          ok {serr} == ""
        end
      end

      spec "[!n0ubh] prints version string and exit when '-v' or '--version' specified." do |app|
        [
          ["-v", "foo", "bar"],
          ["--version", "foo", "bar"],
        ].each do |args|
          sout, serr = Dummy.new.stdouterr do
            status = app.run(args)
            ok {status} == 0
            ok {args} == ["foo", "bar"]
          end
          expected = "#{Skeema::RELEASE}\n"
          ok {sout} == expected
          ok {serr} == ""
        end
      end

      spec "[!saisg] returns 0 as status code when succeeded." do |app|
        [
          #["foo", "bar"],
          [],
        ].each do |args|
          sout, serr = Dummy.new.stdouterr do
            status = app.run(args)
            ok {status} == 0
            ok {args} == [] # ["foo", "bar"]
          end
          ok {sout}.NOT == ""
          ok {serr} == ""
        end
      end

    end


    topic '.main()' do

      spec "[!cy0yo] uses ARGV when args is not passed." do
        bkup = ARGV.dup
        ARGV[0..-1] = ["-h", "-v", "foo", "bar"]
        Dummy.new.stdouterr do
          klass.main()
          ok {ARGV} == ["foo", "bar"]
        end
        ARGV[0..-1] = bkup
      end

      spec "[!t0udo] returns status code (0: ok, 1: error)." do
        Dummy.new.stdouterr do
          status = klass.main(["-hv"])
          ok {status} == 0
          status = klass.main(["-hx"])
          ok {status} == 1
        end
      end

      spec "[!maomq] command-option error is cached and not raised." do
        Dummy.new.stdouterr do
          pr = proc { klass.main(["-hx"]) }
          ok {pr}.NOT.raise?(Skeema::Util::CommandOptionError)
        end
      end

    end


  end


end
