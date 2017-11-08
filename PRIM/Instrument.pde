class InstRandomGranulator implements Instrument
{
  AudioOutput output;
  Oscil osc1;
  Oscil osc2;
  GranulateRandom chopper1;
  GranulateRandom chopper2;
  Noise noise;
  BandPass bp;
  
  Summer sum;
  
  float[] set1 = {0.4, 192};
  float[] set2 = {0.4, 192};
  
  InstRandomGranulator(AudioOutput output)
  {
    this.output = output;

    sum = new Summer();

    osc1 = new Oscil( set1[0], set1[1], Waves.TRIANGLE );
    chopper1 = new GranulateRandom( 0.005, 0.005, 0.001, 0.020, 0.020, 0.002 );    
    
    osc2 = new Oscil( set2[0], set2[1], Waves.TRIANGLE );
    //chopper2 = new GranulateRandom( 0.01, 0.01, 0.1, 0.20, 0.20, 0.02 );
    chopper2 =  new GranulateRandom( 0.005, 0.005, 0.001, 0.020, 0.020, 0.002 );    

    noise = new Noise( 0.2, Noise.Tint.BROWN); // ampl
    bp = new BandPass( 600, 200, output.sampleRate()); // freq, bandwidth
    
    
    osc1.patch( chopper1 );
    osc1.patch( sum );
    osc2.patch( chopper2 );
    osc2.patch( sum );
    noise.patch( bp );
    noise.patch( sum );    
    sum.patch( output );
  }
  
  void setOsc1(float freq, float ampl){
    osc1.setFrequency(freq);  
    osc1.setAmplitude(ampl);  
  }
  
  void setOsc2(float freq, float ampl){
    osc2.setFrequency(freq);  
    osc2.setAmplitude(ampl);  
  }
  
  void setWave(Waveform wave)
  {
    osc1.setWaveform(wave);
    osc2.setWaveform(wave);
  }
  
  void noteOn( float dur )
  {
    chopper1.patch( output ); 
    chopper2.patch( output );
  }
 
  void noteOff()
  {
    chopper1.unpatch( output ); 
    chopper2.unpatch( output );
  }
}