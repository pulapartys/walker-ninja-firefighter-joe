// Scenes for "Extinguisho: Generated Art, Sound, and Music in Godot" (Brutalist godot-gamedev, walker mode).
// Shared scenes come from the Brutalist toolkit through the local `brutalist` link (not committed);
// EvidencePanel is this film's own: one real image (screenshot, generation, diagram, test output)
// with its title, label, and caption, so every image carries its provenance on screen.
import React from 'react';
import {registerRoot,Composition,AbsoluteFill,Img,staticFile,delayRender,continueRender,interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {ClaudeComposerAsk} from './brutalist/scenes/ClaudeComposerAsk';
import {BrutalistHesitantWriter} from './brutalist/scenes/BrutalistHesitantWriter';
import {ClaudeVerdictArtifact} from './brutalist/scenes/ClaudeVerdictArtifact';
import {ClaudeTitleOutro} from './brutalist/scenes/ClaudeTitleOutro';
import {GodotDevWorkbench,godotDevWorkbenchSchema} from './brutalist/scenes/GodotDevWorkbench';
import {GodotDesignFigure,godotDesignFigureSchema} from './brutalist/scenes/GodotDesignFigure';

const fontGate=delayRender('Local fonts');
Promise.all([['EB Garamond','EBGaramond-Regular.ttf'],['Inter','Inter-Regular.ttf'],['PT Mono','PTMono-Regular.ttf']].map(async([family,file])=>{const f=new FontFace(family,`url(${staticFile(file)})`);await f.load();document.fonts.add(f);})).then(()=>continueRender(fontGate));
const INK='#3D3929',BG='#FAF9F5',ACC='#BE593A',EDGE='#C9C4B9',MUTED='#66614F';

type Panel={title:string;label:string;images:string[];captions?:string[];note?:string;durationSeconds?:number;stepSeconds?:number};
// One or more images side by side (or revealed in sequence when stepSeconds is set).
const EvidencePanel:React.FC<Panel>=(p)=>{
 const f=useCurrentFrame(),{fps}=useVideoConfig(),t=f/fps;
 const n=p.images.length,seq=!!p.stepSeconds;
 const shown=seq?Math.min(n,1+Math.floor(t/(p.stepSeconds as number))):n;
 const visible=seq?[p.images[shown-1]]:p.images;
 const caps=seq?[(p.captions||[])[shown-1]]:(p.captions||[]);
 const w=(1920-220-(visible.length-1)*40)/visible.length;
 return <AbsoluteFill style={{background:BG,color:INK,fontFamily:'Inter,sans-serif'}}>
  <div style={{position:'absolute',left:110,right:110,top:52,fontFamily:'"EB Garamond",Georgia,serif',fontSize:62,lineHeight:1.05}}>{p.title}</div>
  <div style={{position:'absolute',left:112,top:136,fontSize:26,color:ACC,letterSpacing:1}}>{p.label}</div>
  <div style={{position:'absolute',left:110,right:110,top:178,height:2,background:EDGE}}/>
  {visible.map((src,i)=><div key={src+i} style={{position:'absolute',top:205,left:110+i*(w+40),width:w,height:seq||n===1?740:700,display:'flex',flexDirection:'column',alignItems:'center',opacity:interpolate(t,[0,.35],[0,1],{extrapolateRight:'clamp'})}}>
   <Img src={staticFile(src)} style={{maxWidth:'100%',maxHeight:caps[i]?650:740,objectFit:'contain',border:`1px solid ${EDGE}`}}/>
   {caps[i]?<div style={{marginTop:14,fontSize:26,lineHeight:1.25,color:MUTED,textAlign:'center'}}>{caps[i]}</div>:null}
  </div>)}
  {p.note?<div style={{position:'absolute',left:112,right:420,bottom:44,fontSize:26,lineHeight:1.3,color:INK}}>{p.note}</div>:null}
  <div style={{position:'absolute',right:110,bottom:44,fontSize:28,fontFamily:'"EB Garamond",Georgia,serif'}}>@NikBearBrown</div>
 </AbsoluteFill>;
};
const Thesis:React.FC<any>=(p)=><BrutalistHesitantWriter {...p} contextTitle="Assignment 2 · an asset slice you can explain" contextItems={[{label:'Generated',detail:'Character states, environment, five sounds, a music loop.'},{label:'Proved',detail:'Running in Godot, tested, playtested, logged.'}]} yOffset={-80} brandLabel="@NikBearBrown"/>;
const Verdict:React.FC<any>=(p)=><ClaudeVerdictArtifact {...p} brandLabel="@NikBearBrown"/>;
const entries:any[]=[['EvidencePanel',EvidencePanel],['ClaudeComposerAsk',ClaudeComposerAsk],['BrutalistHesitantWriter',Thesis],['ClaudeVerdictArtifact',Verdict],['ClaudeTitleOutro',ClaudeTitleOutro],['GodotDevWorkbench',(p:any)=><GodotDevWorkbench {...godotDevWorkbenchSchema.parse(p)}/>],['GodotDesignFigure',(p:any)=><GodotDesignFigure {...godotDesignFigureSchema.parse(p)}/>]];
const Root=()=> <>{entries.map(([id,component])=><Composition key={id} id={id} component={component} width={1920} height={1080} fps={30} durationInFrames={300} defaultProps={{durationSeconds:10}} calculateMetadata={({props})=>({durationInFrames:Math.ceil((props.durationSeconds||10)*30)})}/>)}</>;
registerRoot(Root);
