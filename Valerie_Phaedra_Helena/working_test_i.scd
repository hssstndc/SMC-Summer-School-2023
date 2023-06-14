// SMC Summer School 4: Ambisonics panning with gestural control

//NetAddr.langPort

//s.meter;

(
s.options.numOutputBusChannels = 32;
s.options.numInputBusChannels = 2;

s.waitForBoot{
	// This time we use a stereo soundfile summed to mono
	b = Buffer.read(s,"/Users/phaedra/Downloads/pitched up ambi project1.wav");
	c = Buffer.read(s,"/Users/phaedra/Downloads/coolsound.wav");
	d = Buffer.read(s,"/Users/phaedra/Desktop/3/birds.wav");

	// a synthdef with possibilities to play a soundfile from a certain position and
	// an embedded FoaRTT transformer (rotate, tilt and tumble)

	SynthDef(\soundfile, {|out, buf, freq = 200, amp = 0.1, gate=1, pos, rotate, tilt, tumble|
		var sig, env;
		env = EnvGen.kr(Env.asr(0.3, 1, 1.3), gate, doneAction: 2);
		//mouse = MouseX.kr(10,100,1);
		//mouse2 = MouseY.kr(0.4,15);
		sig = WarpZ.ar(1,buf,pos)*env;
		//sig = BPF.ar(sig, mouse, mouse2, amp);
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

};
)

// Test the source synth. Set the output to the previously defined FOA bus.
x = Synth(\soundfile, [\buf, b, \out, ~foaBus, \pos, 0.1]);
y = Synth(\soundfile, [\buf, c, \out, ~foaBus, \pos, 0.1]);
t = Synth(\soundfile, [\buf, d, \out, ~foaBus, \pos, 0.1]);
x.free;
s.meter;

// trace all incoming OSC messages
OSCFunc.trace(true);
OSCFunc.trace(false);

// define a couple of OSCdefs to trigger and pan sounds
// use the buttons in the app to trigger playback at different positions in the soundfile.

s.meter;

(

OSCdef(\ab, {|msg|
	msg.postln;
	x.set(\rotate, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/slider1');

OSCdef(\cd, {|msg|
	msg.postln;
	x.set(\tilt, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/valerie2');

OSCdef(\def, {|msg|
	msg.postln;
	x.set(\tumble, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/valerie3');

OSCdef(\pos1, {|msg|
	msg.postln;
	x.set(\pos, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/valerie4');

OSCdef(\abc, {|msg|
	msg.postln;
	y.set(\rotate, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/hslider1');

OSCdef(\cde, {|msg|
	msg.postln;
	y.set(\tilt, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/hslider2');

OSCdef(\defe, {|msg|
	msg.postln;
	y.set(\tumble, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/hslider3');

OSCdef(\pos2, {|msg|
	msg.postln;
	y.set(\pos, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/hslider4');

OSCdef(\abe, {|msg|
	msg.postln;
	t.set(\rotate, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/fe1');

OSCdef(\cdr, {|msg|
	msg.postln;
	t.set(\tilt, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/fe2');

OSCdef(\defu, {|msg|
	msg.postln;
	t.set(\tumble, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/fe3');

OSCdef(\pos3, {|msg|
	msg.postln;
	t.set(\pos, msg[1].linlin(0, 1, -pi, pi));
}, '/oscControl/fe4');

//OSCdef(\bc, {|msg|
	//msg.postln;
	//x.set(\gate, msg[1]);
//}, '/oscControl/toggle1');


)


