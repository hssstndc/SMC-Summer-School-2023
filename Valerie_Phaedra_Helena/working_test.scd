// SMC Summer School 4: Ambisonics panning with gestural control

//NetAddr.langPort

s.meter;
(
s.options.numOutputBusChannels = 32;
s.options.numInputBusChannels = 2;

s.waitForBoot{
	// This time we use a stereo soundfile summed to mono
	b = Buffer.read(s,"/Users/phaedra/Desktop/3/hula.wav");

	// a synthdef with possibilities to play a soundfile from a certain position and
	// an embedded FoaRTT transformer (rotate, tilt and tumble)
	SynthDef(\soundfile, {|out, buf, rate = 1, gate = 1, pos, rotate, tilt, tumble|
		var sig, env;
		env = EnvGen.kr(Env.asr(0.02, 1, 0.9), gate, doneAction: 2);
		sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, gate, pos * BufFrames.kr(buf), 1);
		// sum to mono and apply envelope
		sig = sig.sum * env;
		// encode the signal using newDirection set to the default values"/Users/phaedra/Downloads/KMHLS_Dome_1h1p_N.scx"
		sig = FoaEncode.ar(sig, FoaEncoderMatrix.newDirection(0, 0));
		sig = FoaTransform.ar(sig, 'rtt', rotate.lag(0.02), tilt.lag(0.02), tumble.lag(0.02));
		Out.ar(out, sig);
	}).add;

	// First Order Ambisonics Decoder Synth for Lilla Salen
	SynthDef(\LSfoaDecoder, {|foaInput|
		var foa;
		foa = In.ar(foaInput, 4);
		Out.ar(0, KMHLSDome1h1pN.ar(*foa));
	}).add;


	s.sync;


	~sources = Group(s);
	~foaBus = Bus.audio(s, 4); // an internal bus to use for the 4 channel Ambisonics B-format signal

	s.sync;

	// start your preferred decoder synth and make sure it is placed after the transforms group
	~decoder = Synth.after(~sources, \LSfoaDecoder, [\foaInput, ~foaBus]);
	//~decoder = Synth.after(~sources, \PHfoaDecoder, [\foaInput, ~foaBus]);
	//~decoder = Synth.after(~sources, \UHJfoaDecoder, [\foaInput, ~foaBus]);
};
)

// Test the source synth. Set the output to the previously defined FOA bus.
x = Synth(\soundfile, [\buf, b, \out, ~foaBus, \pos, 0.1]);
x.free;
s.meter;

/*
Use phone sensors to trigger the sound and control panning.
For this example i'm using an app called GyrOSC. Available here:
http://www.bitshapes`oftware.com/instruments/gyrosc/

To receive OSC data from the phone we need to:
1. Make sure the devices are on the same network
2. Set the app in your phone to send to the IP of your computer and check the port it's sending on.
3. Create OSC responder functions to deal with the incoming data.

In SC we can use OSCFunc or OSCdef to define those responder functions.
We need to know the OSC address to be able to separate the messages.
*/

FoaXformDisplay();

// trace all incoming OSC messages
OSCFunc.trace(true);
OSCFunc.trace(false);

// define a couple of OSCdefs to trigger and pan sounds
// use the buttons in the app to trigger playback at different positions in the soundfile.



(
OSCdef(\valerie, {|msg|
	msg.postln;
	x.set(\rotate, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/slider1');

OSCdef(\phaedra, {|msg|
	msg.postln;
	x.set(\tilt, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/slider2');

OSCdef(\helena, {|msg|
	msg.postln;
	x.set(\tumble, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/slider3');
)