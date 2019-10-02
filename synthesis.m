%% PLOT SPECTOGRAM OF THE INSTRUMENTS
close all;
clear;

plot_spectrogram('Piano_mf_A4.wav', 5000);
plot_spectrogram('Trumpet_novib_A4.wav', 15000);

%% SYNTHESIZE PIANO
close all;
clear;

plot_spectrogram('Piano_mf_A4.wav', 5000);
% Based on the spectrogram, the pitch/fundamental freq
% is at 440Hz

[x, fs] = audioread('Piano_mf_A4.wav');
t = 0 : 1/fs : length(x)/fs;
ff = 440;   % fundamental frequency

% create the envelope
env = hilbert(x, length(t));
env = abs(env);
env = env ./ max(abs(env));
env = env';

% [attack,delay,sustain,release,P,adsr_time] = getADSR(x, fs);
% P = interp1(adsr_time, P, t);
% P = P ./ max(P);

figure();
plot(t, env);

signal = zeros(length(x) + 1,1)';

for k = 1:6
    % create sine wave
    new_signal = sin(2*pi*(ff * k));
    % add envelope
    new_signal = new_signal .* env;
    % new_signal = new_signal .* P;
    
    signal = signal + new_signal;
end

% add filters to remove unnecessary frequencies
[b,a] = butter(2, 3000 / fs, 'high');
signal = filter(b,a,signal);

signal = signal ./ max(abs(signal));

figure();
spectrogram(signal, power(2,10), [], 0:5000, fs, 'yaxis');
soundsc(signal, fs);
% audiowrite('piano_synth.wav', signal, fs);

%% SYNTHESIZE SNARE
close all;
[snare,snareFS] = audioread('snare.wav');
soundsc(snare, snareFS);
pause;
figure;plot_spectrogram('snare.wav', 10000);

% Check Snare Spectrum
snareFFT = fft(snare);
snareMag = abs(snareFFT);
snareMag = snareMag./max(snareMag);
figure;plot(linspace(0, snareFS, length(snare)), 20*log10(snareMag));
axis([0 1000 -40 10]);
% Has a peak at around 160Hz


% Extract ADSR params
[snareAttack, snareDecay, snareSustain, snareRelease, t, P, sDuration] = getADSR(snare(:,1), snareFS);

% Generate ADSR envelope
snareADSREnvelope = ADSRenvelope(snareAttack, snareDecay, snareSustain, snareRelease,sDuration,8000);

% Synthesize using Karplus Strong
synthSnare=karplus_strong_drum(snareADSREnvelope, snareFS, round(snareFS/160),0.4);
soundsc(synthSnare,snareFS);

%% SYNTHESIZE TRUMPET
close all;
clear;

plot_spectrogram('Trumpet_novib_A4.wav', 15000);

[x, fs] = audioread('Trumpet_novib_A4.wav');
t = 0 : 1/fs : length(x)/fs;
ff = 440;   % fundamental frequency

% create the envelope
[a,d,s,r,tP,P,sDuration] = getADSR(x, fs);
[tenv, env] = ADSRenvelope(a,d,s,r,4,fs);
env = interp1(tenv, env, t);
signal = zeros(length(x) + 1,1)';

figure();
plot(t, env);

amp = 1;

for k = 1:10
    % create sine wave
    new_signal = sin(2*pi*(ff * k)*t) * amp;
    % add envelope
    new_signal = new_signal .* env;
    
    if k == 2 || k == 4 || k == 8
        amp = amp / 4;
    end
    
    signal = signal + new_signal;
end

% add filters to remove unnecessary frequencies
% [b,a] = butter(2, 100 / fs, 'high');
% signal = filter(b,a,signal);
 
signal = signal ./ max(abs(signal));

figure();
plot(t, signal);
title('Final Signal');

figure();
spectrogram(signal, power(2,10), [], 0:15000, fs, 'yaxis');

% soundsc(x, fs);
% pause(8);
soundsc(signal, fs);

