// Scenes for "Extinguisho's Puff and Steam" (Assignment 6; Brutalist godot-gamedev, walker mode). Adapted from the A5 film's index.tsx.
// Shared scenes come from the Brutalist toolkit through the local `brutalist` link (not committed).
import React from 'react';
import {registerRoot,Composition} from 'remotion';
import {ClaudeComposerAsk} from './brutalist/scenes/ClaudeComposerAsk';
import {BrutalistHesitantWriter} from './brutalist/scenes/BrutalistHesitantWriter';
import {ClaudeVerdictArtifact} from './brutalist/scenes/ClaudeVerdictArtifact';
import {ClaudeTitleOutro} from './brutalist/scenes/ClaudeTitleOutro';
import {GodotDevWorkbench,godotDevWorkbenchSchema} from './brutalist/scenes/GodotDevWorkbench';
import {GodotDesignFigure,godotDesignFigureSchema} from './brutalist/scenes/GodotDesignFigure';

const Thesis:React.FC<any>=(p)=><BrutalistHesitantWriter {...p} contextTitle="Assignment 6 · two particle effects an agent cannot see" contextItems={[{label:'Built',detail:'A landing puff and steam that follows the fire, from her brief.'},{label:'Checked',detail:'Headless tests for timing; frames and her eyes for the look.'}]} yOffset={-80} brandLabel="@NikBearBrown"/>;
const Verdict:React.FC<any>=(p)=><ClaudeVerdictArtifact {...p} brandLabel="@NikBearBrown"/>;
const entries:any[]=[['ClaudeComposerAsk',ClaudeComposerAsk],['BrutalistHesitantWriter',Thesis],['ClaudeVerdictArtifact',Verdict],['ClaudeTitleOutro',ClaudeTitleOutro],['GodotDevWorkbench',(p:any)=><GodotDevWorkbench {...godotDevWorkbenchSchema.parse(p)}/>],['GodotDesignFigure',(p:any)=><GodotDesignFigure {...godotDesignFigureSchema.parse(p)}/>]];
const Root=()=> <>{entries.map(([id,component])=><Composition key={id} id={id} component={component} width={1920} height={1080} fps={30} durationInFrames={300} defaultProps={{durationSeconds:10}} calculateMetadata={({props})=>({durationInFrames:Math.ceil((props.durationSeconds||10)*30)})}/>)}</>;
registerRoot(Root);
