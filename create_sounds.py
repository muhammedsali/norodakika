import wave
import struct
import math
import os

SOUNDS_DIR = 'assets/sounds'
if not os.path.exists(SOUNDS_DIR):
    os.makedirs(SOUNDS_DIR)

# Sample rate
SAMPLE_RATE = 44100

def generate_tone(filename, duration, start_freq, end_freq=None, waveform='sine'):
    print(f"Generating {filename}...")
    filepath = os.path.join(SOUNDS_DIR, filename)
    num_samples = int(duration * SAMPLE_RATE)
    
    if end_freq is None:
        end_freq = start_freq

    with wave.open(filepath, 'w') as wav_file:
        nchannels = 1
        sampwidth = 2
        framerate = SAMPLE_RATE
        nframes = num_samples
        comptype = "NONE"
        compname = "not compressed"
        wav_file.setparams((nchannels, sampwidth, framerate, nframes, comptype, compname))
        
        for i in range(num_samples):
            # Interpolate frequency
            t = i / SAMPLE_RATE
            freq = start_freq + (end_freq - start_freq) * (i / num_samples)
            
            if waveform == 'sine':
                value = math.sin(2 * math.pi * freq * t)
            elif waveform == 'square':
                value = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
            
            # Envelope (fade in/out to avoid clipping)
            envelope = 1.0
            if i < 400: envelope = i / 400
            elif i > num_samples - 400: envelope = (num_samples - i) / 400
                
            value = value * 20000 * envelope
            data = struct.pack('<h', int(value))
            wav_file.writeframesraw(data)

# correct.wav: quick high pitched double beep
generate_tone('correct.wav', 0.15, 800, 1000)
# wrong.wav: low pitched buzz
generate_tone('wrong.wav', 0.3, 150, 100, waveform='square')
# tap.wav: extremely short plik
generate_tone('tap.wav', 0.05, 600, 400)
# success.wav: nice ascending tone
generate_tone('success.wav', 0.4, 400, 1200)
# game_over.wav: decreasing tone
generate_tone('game_over.wav', 0.5, 400, 200)
# countdown.wav: short single beep
generate_tone('countdown.wav', 0.1, 800)
# level_up.wav: complex successful ascending
generate_tone('level_up.wav', 0.6, 500, 1500)

print("All sounds generated.")
