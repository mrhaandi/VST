Require Import VST.veric.juicy_base.
Require Import VST.msl.normalize.
Require Import VST.veric.juicy_mem VST.veric.juicy_mem_lemmas VST.veric.juicy_mem_ops.
Require Import VST.veric.res_predicates.
Require Import VST.veric.extend_tc.
Require Import VST.veric.Clight_seplog.
Require Import VST.veric.Clight_assert_lemmas.
Require Import VST.veric.Clight_core.
Require Import VST.sepcomp.extspec.
Require Import VST.sepcomp.step_lemmas.
Require Import VST.veric.juicy_extspec.
Require Import VST.veric.tycontext.
Require Import VST.veric.expr2.
Require Import VST.veric.expr_lemmas.
Require Import VST.veric.semax.
Require Import VST.veric.semax_lemmas.
Require Import VST.veric.semax_conseq.
Require Import VST.veric.Clight_lemmas.

Local Open Scope pred.
Local Open Scope nat_scope.

Section extensions.
Context {CS: compspecs} {Espec : OracleKind}.

Lemma tc_test_eq1:
  forall b i v m,
  (denote_tc_test_eq (Vptr b i) v) (m_phi m) ->
  Mem.weak_valid_pointer (m_dry m) b (Ptrofs.unsigned i) = true.
Proof.
intros.
destruct v; try destruct H.
apply binop_lemmas4.weak_valid_pointer_dry in H0;
apply H0.
simpl in H.
unfold test_eq_ptrs in H.
destruct (sameblock (Vptr b i) (Vptr b0 i0)).
destruct H;
apply binop_lemmas4.weak_valid_pointer_dry in H; auto.
destruct H.
apply valid_pointer_implies.
apply binop_lemmas4.valid_pointer_dry in H.
rewrite Z.add_0_r in H. auto.
Qed.

Lemma semax_ifthenelse:
   forall Delta P (b: expr) c d R,
      bool_type (typeof b) = true ->
     semax Espec Delta (fun rho => P rho && !! expr_true b rho) c R ->
     semax Espec Delta (fun rho => P rho && !! expr_false b rho) d R ->
     semax Espec Delta
              (fun rho => tc_expr Delta (Eunop Cop.Onotbool b (Tint I32 Signed noattr)) rho && P rho)
              (Sifthenelse b c d) R.
Proof.
intros.
rewrite semax_unfold in H0, H1 |- *.
intros.
specialize (H0 psi _ _ _ TS HGG Prog_OK k F f).
specialize (H1 psi _ _ _ TS HGG Prog_OK k F f).
spec H0.  {
  intros i te' ?.  apply H2; simpl; auto. intros i0; destruct (H4 i0); try tauto; intuition.
  left; clear - H5.
 unfold modifiedvars. simpl.
 apply modifiedvars'_union. left; apply H5.
}
spec H1. {
 intros i te' ?.  apply H2; simpl; auto.
 clear - H4; intros i0; destruct (H4 i0); try tauto; intuition.
 left.
 unfold modifiedvars. simpl.
 apply modifiedvars'_union. right; apply H.
}
assert (H3then: app_pred
       (rguard Espec psi Delta' f (frame_ret_assert R F) k) w).
clear - H3.
intros ek vl tx vx; specialize (H3 ek vl tx vx).
cbv beta in H3.
eapply subp_trans'; [ | apply H3].
apply derives_subp; apply andp_derives; auto.
assert (H3else: app_pred
       (rguard Espec psi Delta' f (frame_ret_assert R F) k) w).
clear - H3.
intros ek vl tx vx; specialize (H3 ek vl tx vx).
eapply subp_trans'; [ | apply H3].
apply derives_subp; apply andp_derives; auto.
specialize (H0 H3then).
specialize (H1 H3else).
clear Prog_OK H3 H3then H3else.
intros tx vx; specialize (H0 tx vx); specialize (H1 tx vx).
remember (construct_rho (filter_genv psi) vx tx) as rho.
slurp.
rewrite <- fash_and.
intros a' a'' ? Hext. clear w H0.
apply fash_derives.
intros w [? ?].
intros ? ?w ? Hext' [[?TC  ?] ?].
assert (typecheck_environ Delta rho) as TC_ENV. {
  destruct TC as [TC _].
  eapply typecheck_environ_sub; eauto.
}
apply extend_sepcon_andp in H4; auto.
destruct H4 as [TC2 H4].
pose proof TC2 as TC2'.
apply (tc_expr_sub _ _ _ TS) in TC2'; [| auto].
destruct H4 as [w1 [w2 [? [? ?]]]].
specialize (H0 _ _ H3 Hext').
specialize (H1 _ _ H3 Hext').
unfold expr_true, expr_false, Cnot in *.

pose proof (typecheck_expr_sound _ _ _ _ TC_ENV TC2) as HTCb; simpl in HTCb.
unfold liftx, lift, eval_unop in HTCb; simpl in HTCb.
destruct (bool_val (typeof b) (eval_expr b rho)) as [b'|] eqn: Hb; [|contradiction].
assert (assert_safe Espec psi f vx tx (Cont (Kseq (if b' then c else d) k))
  (construct_rho (filter_genv psi) vx tx) w0) as Hw0.
{ unfold tc_expr in TC2; simpl in TC2.
  rewrite denote_tc_assert_andp in TC2; destruct TC2.
  destruct b'; [apply H0 | apply H1]; split; subst; auto; split; auto; do 3 eexists; eauto; split;
    auto; split; auto; apply bool_val_strict; auto; eapply typecheck_expr_sound; eauto. }
destruct HGG as [CSUB HGG]. apply (@tc_expr_cenv_sub _ _ CSUB) in TC2'. 
eapply own.bupd_mono, bupd_denote_tc; eauto. 
intros r [Htc Hr] ora jm Hora Hge Hphi ?. 
generalize (eval_expr_relate _ _ _ _ _ b jm HGG Hge (guard_environ_e1 _ _ _ TC)); intro.
generalize LW; intro H9.
subst r.
change (level (m_phi jm)) with (level jm) in H9.
revert H9; case_eq (level jm); intros.
lia.
apply levelS_age1 in H9. destruct H9 as [jm' ?].
clear H10.
apply jsafe_step'_back2 with (st' := State f (if b' then c else d) k vx tx)
  (m' := jm').
split3.
assert (TCS := typecheck_expr_sound _ _ (m_phi jm) _ (guard_environ_e1 _ _ _ TC) Htc). 
unfold tc_expr in Htc.
simpl in Htc.
rewrite denote_tc_assert_andp in Htc.
clear TC2'; destruct Htc as [TC2' TC2'a].
rewrite <- (age_jm_dry H9); econstructor; eauto.
{
 assert (exists b': bool, Cop.bool_val (@eval_expr CS' b rho) (typeof b) (m_dry jm) = Some b') as [].
  { clear - TS TC H TC2 TC2' TC2'a TCS CSUB.
    simpl in TCS. unfold_lift in TCS.
    unfold Cop.bool_val;
      destruct (@eval_expr CS' b rho) eqn:H15;
      simpl; destruct (typeof b) as [ | [| | | ] [| ]| | [ | ] |  | | | | ] eqn:?;
      try tauto; simpl in *; try rewrite TCS; eauto.
  all: try apply (tc_expr_cenv_sub CSUB) in TC2.
    all: try (
             unfold tc_expr in TC2; simpl typecheck_expr in TC2; rewrite Heqt in TC2;
             rewrite denote_tc_assert_andp in TC2; destruct TC2 as [_ TC2];
             destruct TC as [TC _];
             assert (H2 := typecheck_expr_sound _ _ _ _  (typecheck_environ_sub _ _ TS _ TC) TC2);
             rewrite Heqt, H15 in H2; contradiction H2).
   all:   rewrite denote_tc_assert_andp in TC2'; destruct TC2' as [TC2'' TC2'];
      rewrite binop_lemmas2.denote_tc_assert_test_eq' in  TC2';
      simpl in TC2'; unfold_lift in TC2';  try rewrite H15 in TC2'.
    all: destruct Archi.ptr64 eqn:Hp; try contradiction; eauto.
    all: try (apply tc_test_eq1 in TC2'; simpl; rewrite TC2'; eauto).
  }
  apply (bool_val_cenv_sub CSUB) in Hb.
  rewrite H10; symmetry; eapply f_equal, bool_val_Cop; eauto. }
apply age1_resource_decay; auto.
split; [apply age_level; auto|].
erewrite (age1_ghost_of _ _ (age_jm_phi H9)) by (symmetry; apply ghost_of_approx).
repeat intro; auto.
change (level (m_phi jm)) with (level jm).
replace (level jm - 1)%nat with (level jm' ) by (apply age_level in H9; lia).
eapply @age_safe; try apply H9.
rewrite <- Hge in *.
apply Hr; auto.
Qed.

Ltac inv_safe H :=
  inv H;
  try solve[match goal with
    | H : semantics.at_external _ _ _ = _ |- _ =>
      simpl in H; congruence
    | H : j_at_external _ _ _ = _ |- _ =>
      simpl in H; congruence
    | H : semantics.halted _ _ _ |- _ =>
      simpl in H; unfold cl_halted in H; contradiction
  end].

Lemma semax_seq:
  forall Delta (R: ret_assert) P Q h t,
  semax Espec Delta P h (overridePost Q R) ->
  semax Espec Delta Q t R ->
  semax Espec Delta P (Clight.Ssequence h t) R.
Proof.
intros.
rewrite semax_unfold in H,H0|-*.
intros.
specialize (H psi _ CS' w TS HGG Prog_OK).
specialize (H0 psi Delta' CS' w).
spec H0; auto.
spec H0; auto.
spec H0. {
clear - Prog_OK.
unfold believe in *.
unfold believe_internal in *.
intros v fsig cc A P Q; specialize (Prog_OK v fsig cc A P Q).
intros ? a' ? Hext H0. specialize (Prog_OK _ _ H Hext).
spec Prog_OK.
destruct H0 as [id [NEP [NEQ [? ?]]]]. exists id, NEP, NEQ; split; auto.
auto.
}
assert ((guard Espec psi Delta' f (fun rho : environ => F rho * P rho)%pred
(Kseq h (Kseq t k))) w).
2:{
eapply guard_safe_adj'; try apply H3; try reflexivity.
intros.
eapply jsafeN_local_step.
constructor.
intros.
eapply age_safe; eauto.
}
eapply H; eauto.
repeat intro; apply H1.
clear - H3. intro i; destruct (H3 i); [left | right]; auto.
unfold modifiedvars in H|-*. simpl. apply modifiedvars'_union.
left; auto.
clear - HGG H0 H1 H2.
intros ek vl.
intros tx vx.
rewrite proj_frame_ret_assert.
destruct (eq_dec ek EK_normal).
*
subst.
unfold exit_cont.
unfold guard in H0.
remember (construct_rho (filter_genv psi) vx tx) as rho.
assert (app_pred
(!!guard_environ Delta' f rho &&
(F rho * (Q rho)) && funassert Delta' rho >=>
assert_safe Espec psi f vx tx (Cont (Kseq t k)) rho)%pred w). {
subst.
specialize (H0 k F f).
spec H0.
clear - H1;
repeat intro; apply H1. simpl.
intro i; destruct (H i); [left | right]; auto.
unfold modifiedvars in H0|-*. simpl. apply modifiedvars'_union.
auto.
spec H0.
clear - H2.
intros ek vl te ve; specialize (H2 ek vl te ve).
eapply subp_trans'; [ | apply H2].
apply derives_subp. apply andp_derives; auto.
specialize (H0 tx vx). cbv beta in H0.
apply H0.
}
simpl proj_ret_assert.
destruct vl.
repeat intro. destruct H6 as [[_ [? [? [? [[? _] _]]]]] _]; discriminate.
eapply subp_trans'; [ | apply H].
apply derives_subp. apply andp_derives; auto.
 apply andp_derives; auto.
rewrite sepcon_comm;
apply sepcon_derives; auto.
apply andp_left2.
destruct R; simpl; auto.
*
replace (exit_cont ek vl (Kseq t k)) with (exit_cont ek vl k)
by (destruct ek; simpl; congruence).
unfold rguard in H2.
specialize (H2 ek vl tx vx).
eapply subp_trans'; [ | apply H2].
apply derives_subp.
apply andp_derives; auto.
apply andp_derives; auto.
rewrite proj_frame_ret_assert.
destruct R, ek; simpl; auto. contradiction n; auto.
Qed.

(*
Lemma control_as_safe_refl psi n k : control_as_safe psi n k k.
Proof.
hnf.
intros ??? H; inversion 1; subst. constructor.
econstructor; eauto.
simpl in *. congruence.
simpl in H1. unfold cl_halted in H1. congruence.
Qed.
*)

(*
Definition control_as_safex {Espec: OracleKind} ge n c1 k1 c2 k2 :=
    forall (ora : OK_ty) f (ve : env) (te : temp_env) (m : juicy_mem) (n' : nat),
        n' <= n ->
        jsafeN (@OK_spec Espec) ge n' ora (State f c1 k1 ve te) m ->
          jsafeN (@OK_spec Espec) ge n' ora (State f c2 k2 ve te) m.
*)

Lemma semax_loop:
forall Delta Q Q' incr body R,
     semax Espec Delta Q body (loop1_ret_assert Q' R) ->
     semax Espec Delta Q' incr (loop2_ret_assert Q R) ->
     semax Espec Delta Q (Sloop body incr) R.
Proof.
  intros ? ? ? ? ?  POST H H0.
  rewrite semax_unfold.
  intros until 4.
  rename H1 into H2.
  assert (CLO_body: closed_wrt_modvars body F).
  {
    clear - H2. intros rho te ?. apply (H2 rho te). simpl.
    intro; destruct (H i); auto. left; unfold modifiedvars in H0|-*; simpl;
    apply modifiedvars'_union; auto.
  }
  assert (CLO_incr:  closed_wrt_modvars incr F).
  {
    clear - H2. intros rho te ?. apply (H2 rho te). simpl.
    intro; destruct (H i); auto. left; unfold modifiedvars in H0|-*; simpl;
    apply modifiedvars'_union; auto.
  }
  revert Prog_OK; induction w using (well_founded_induction lt_wf); intros.
  intros tx vx.
  intros ? ? ? ? ? Hext [[? ?] ?]. hnf in H6.
  apply assert_safe_last; intros a2 LEVa2.
  assert (NEC2: necR w (level a2)).
  {
    apply age_level in LEVa2. apply necR_nat in H5. apply nec_nat in H5.
    change w with (level w) in H4|-*. apply nec_nat. apply ext_level in Hext. clear - H4 H5 LEVa2 Hext.
    lia.
  }
  assert (LT: level a2 < level w).
  {
    apply age_level in LEVa2. apply necR_nat in H5. apply ext_level in Hext.
    clear - H4 H5 LEVa2 Hext.
    change w with (level w) in H4.
    change R.rmap with rmap in *.  rewrite LEVa2 in *.  clear LEVa2.
    apply nec_nat in H5. lia.
  }
  assert (Prog_OK2: (believe Espec Delta' psi Delta') (level a2))
    by (apply pred_nec_hereditary with w; auto).
  generalize (pred_nec_hereditary _ _ _ NEC2 H3); intro H3'.
  remember (construct_rho (filter_genv psi) vx tx) as rho.
  pose proof I.
  eapply semax_Delta_subsumption in H; try apply TS; auto.
  eapply semax_Delta_subsumption in H0; try apply TS; auto.
  clear Delta TS.
  generalize H; rewrite semax_unfold; intros H'.
  apply own.bupd_intro.
  intros ora jm Hora RE ?; subst.
  destruct (can_age1_juicy_mem _ _ LEVa2) as [jm2 LEVa2'].
  unfold age in LEVa2.
  assert (a2 = m_phi jm2).
  {
    generalize (age_jm_phi LEVa2'); unfold age; change R.rmap with rmap.
    change R.ag_rmap with ag_rmap; rewrite LEVa2.
    intro Hx; inv Hx; auto.
  }
  intro.
  subst a2.
  rewrite (age_level _ _ LEVa2).
  apply jsafeN_step
   with (State f body (Kloop1 body incr k) vx tx)
          jm2.
  {
    split.
    rewrite <- (age_jm_dry LEVa2').
    constructor.
    split3.
    + apply age1_resource_decay; auto.
    +apply age_level; auto.
    +  apply age1_ghost_of; auto.
  }
  apply assert_safe_jsafe; auto.
  assert (H10 := laterR_necR (age_laterR LEVa2')).
  specialize (H1 (level jm2) LT).
  clear RE w NEC2 Prog_OK H3 H4 LT y H5.
  assert (H10' := laterR_necR (age_laterR (age_jm_phi LEVa2'))).
  eapply ext_join_approx in Hora. erewrite <- necR_ghost_of in Hora by eauto.
  apply (pred_nec_hereditary _ _ _  H10') in H7.
  apply (pred_nec_hereditary _ _ _  H10') in H8.
  clear jm Hext LEVa2 LEVa2' LW H10 H10' H9.
  rename H3' into H3. rename Prog_OK2 into Prog_OK.
  specialize (H' psi Delta' CS' (level jm2) (tycontext_sub_refl _) HGG Prog_OK).
  specialize (H' (Kloop1 body incr k) F f CLO_body).
  specialize (H1 Prog_OK H3).
  rename jm2 into jm.
  spec H'. {
   clear H'.
  intros ek vl.
  destruct ek.
  + simpl exit_cont.
    rewrite semax_unfold in H0.
    specialize (H0 psi _ CS' (level jm) (tycontext_sub_refl _)  HGG Prog_OK (Kloop2 body incr k) F f CLO_incr).
    spec H0.    {
      intros ek2 vl2 tx2 vx2; unfold loop2_ret_assert.
      destruct ek2.
      +  simpl proj_ret_assert.
          destruct vl2. intros ? ? ? ? ? Hext [[_ [? _]] _]; discriminate.
          rewrite (prop_true_andp (None=None)) by auto.
        apply @assert_safe_adj' with (k:=Kseq (Sloop body incr) k); auto.
        - simpl; repeat intro. auto.
        - eapply subp_trans'; [ |  eapply H1].
          apply derives_subp.
          apply andp_derives; auto.
          apply andp_derives; auto.
          destruct POST; simpl.
          unfold frame_ret_assert. normalize.
          rewrite sepcon_comm. auto.
      + unfold exit_cont.
        apply @assert_safe_adj' with (k:= k); auto.
        - simpl. destruct k; simpl; auto; hnf; auto.
        - simpl proj_ret_assert.
          eapply subp_trans'; [ |  eapply (H3 EK_normal None tx2 vx2)].
          apply derives_subp.
          apply andp_derives; auto.
          apply andp_derives; auto.
          simpl exit_cont.
          rewrite proj_frame_ret_assert. simpl proj_ret_assert. simpl seplog.sepcon.
          normalize.
          destruct POST; simpl; auto.
      + rewrite proj_frame_ret_assert. simpl seplog.sepcon.
        destruct POST; simpl tycontext.RA_continue. cbv zeta. normalize.
      + rewrite proj_frame_ret_assert.
        change (exit_cont EK_return vl2 (Kloop2 body incr k))
          with (exit_cont EK_return vl2 k).
        eapply subp_trans'; [ | apply H3].
        rewrite proj_frame_ret_assert.
        clear. simpl proj_ret_assert.
        destruct POST; simpl tycontext.RA_return.
        apply subp_refl'.
    }
    intros tx2 vx2.
    destruct vl.
    simpl proj_ret_assert.
    intros ? ? ? ? ? Hext [[_ [? _]] _]; discriminate.
    apply @assert_safe_adj' with (k:= Kseq incr (Kloop2 body incr k)); auto.
    simpl. repeat intro. eapply jsafeN_local_step. econstructor; auto.
    intros; eapply age_safe; eauto.
    eapply subp_trans'; [ | apply H0].
    apply derives_subp.
    unfold frame_ret_assert.
    apply andp_derives; auto.
    apply andp_derives; auto.
    simpl exit_cont.
    rewrite sepcon_comm. destruct POST; simpl proj_ret_assert. normalize.
  + intros tx3 vx3.
    rewrite proj_frame_ret_assert. simpl proj_ret_assert.
    simpl seplog.sepcon. cbv zeta.
    eapply subp_trans'; [ | apply (H3 EK_normal None tx3 vx3)].
    rewrite proj_frame_ret_assert.
    destruct POST; simpl tycontext.RA_break; simpl proj_ret_assert.
    apply derives_subp. simpl seplog.sepcon.
    apply andp_derives; auto.
    normalize.
  + simpl exit_cont.
    rewrite proj_frame_ret_assert.
    intros tx2 vx2. cbv zeta. simpl seplog.sepcon.
    destruct POST; simpl tycontext.RA_continue.
    rewrite semax_unfold in H0.
    eapply subp_trans'; [ | apply (H0 _ _ CS' _ (tycontext_sub_refl _) HGG Prog_OK (Kloop2 body incr k) F f CLO_incr)].
    {
      apply derives_subp.
      apply andp_derives; auto.
      rewrite sepcon_comm.
      apply andp_derives; auto. normalize.
    }
    clear tx2 vx2.
    intros ek2 vl2 tx2 vx2.
    destruct ek2.
    {
    unfold exit_cont.
    destruct vl2.
    intros ? ? ? ? ? Hext [[_ [? _]] _]; discriminate.
    apply @assert_safe_adj' with (k:=Kseq (Sloop body incr) k); auto.
    - repeat intro. auto.
    - eapply subp_trans'; [ | eapply H1; eauto].
      apply derives_subp.
      apply andp_derives; auto.
      apply andp_derives; auto.
      * unfold exit_cont, loop2_ret_assert; normalize.
        specialize (H3 EK_return None tx2 vx2).
        intros tx4 vx4.
        rewrite proj_frame_ret_assert in H3, vx4.
        simpl seplog.sepcon in H3,vx4. cbv zeta in H3, vx4.
        normalize in vx4.        
        rewrite sepcon_comm; auto.
    }
    {
    unfold exit_cont.
    apply @assert_safe_adj' with (k := k); auto.
    - simpl. destruct k; simpl; repeat intro; auto.
    - 
    destruct vl2.
    intros ? ? ? ? ? Hext [[_ [? _]] _]; discriminate.
    eapply subp_trans'; [ |  eapply (H3 EK_normal None tx2 vx2)].
      apply derives_subp.
      auto.
    }
    - simpl proj_ret_assert in H3|-*. cbv zeta. normalize.
    - simpl proj_ret_assert in H3|-*. cbv zeta. 
      specialize (H3 EK_return vl2).
      eapply subp_trans'; [ | eapply H3; eauto].
      auto.
  + intros tx4 vx4. cbv zeta.
    eapply subp_trans'; [ | eapply (H3 EK_return) ; eauto].
    simpl proj_ret_assert. destruct POST; simpl tycontext.RA_return.
    apply subp_refl'. }
  specialize (H' tx vx _ (le_refl _) _ _ (necR_refl _) (ext_refl _)); spec H'.
  { subst; split; auto; split; auto. }
 auto.
Qed.

Lemma semax_break:
   forall Delta Q,        semax Espec Delta (RA_break Q) Sbreak Q.
Proof.
  intros.
  rewrite semax_unfold; intros.  clear Prog_OK. rename w into n.
  intros te ve w ?.
  specialize (H0 EK_break None te ve w H1).
  simpl exit_cont in H0.
  clear n H1.
  remember ((construct_rho (filter_genv psi) ve te)) as rho.
  revert w H0.
  apply imp_derives; auto.
  apply andp_derives; auto.
  repeat intro.
  rewrite proj_frame_ret_assert. simpl proj_ret_assert; simpl seplog.sepcon.
  rewrite sepcon_comm. rewrite (prop_true_andp (None=None)) by auto.
  eapply andp_derives; try apply H0; auto.
  apply own.bupd_mono.
  intros ???? Hora ?? ?.
  specialize (H0 ora jm Hora H1 H2 LW). subst a.
  destruct (break_cont k) eqn:?H; try contradiction.
2:{ elimtype False; clear - H2. revert o c H2; induction k; simpl; intros; try discriminate. eauto. }
  destruct c; try contradiction.
- 
  induction k; try discriminate.
 + simpl in H2. apply IHk in H2. eapply jsafeN_local_step. constructor. intros. eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop1.
    intros.
    eapply age_safe; eauto.
    change (level (m_phi jm)) with (level jm) in H0.
    destruct (level jm). constructor.
    inv H0; [ | discriminate | contradiction].
    destruct H4.
    inv H0.
    eapply jsafeN_step.  split. econstructor; try eassumption.
    hnf; auto. auto. auto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop2.
    intros.
    eapply age_safe; eauto.
    change (level (m_phi jm)) with (level jm) in H0.
    destruct (level jm). constructor.
    inv H0; [ | discriminate | contradiction].
    destruct H4.
    inv H0.
    eapply jsafeN_step.  split. econstructor; try eassumption.
    hnf; auto. auto. auto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. econstructor; auto. 
    intros.
    eapply age_safe; eauto.
    change (level (m_phi jm)) with (level jm) in H0.
    destruct (level jm). constructor.
    inv H0; [ | discriminate | contradiction].
    destruct H4.
    inv H0.
    eapply jsafeN_step.  split. econstructor; try eassumption.
    hnf; auto. auto. auto.
-
  rename c into k'.
  revert s k' H2 H0.
  induction k; simpl; intros; try discriminate.
 +
  eapply jsafeN_local_step. constructor. intros.
  eapply age_safe; try eassumption.
  eapply IHk; eauto.
 +
  inv H2.
  eapply jsafeN_local_step. apply step_break_loop1. intros.
  eapply age_safe; try eassumption.
  eapply jsafeN_local_step. apply step_skip_seq. intros.
  eapply age_safe; try eassumption.
 +
  inv H2.
  eapply jsafeN_local_step. apply step_break_loop2. intros.
  eapply age_safe; try eassumption.
  eapply jsafeN_local_step. apply step_skip_seq. intros.
  eapply age_safe; try eassumption.
 +
  inv H2.
  eapply jsafeN_local_step. apply step_skip_break_switch; auto. intros.
  eapply age_safe; try eassumption.
  eapply jsafeN_local_step. apply step_skip_seq. intros.
  eapply age_safe; try eassumption.
-
  induction k; try discriminate.
 + simpl in H2. apply IHk in H2. eapply jsafeN_local_step. constructor. intros. eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop1.
    intros.
    eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop2.
    intros.
    eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_skip_break_switch; auto.
    intros.
    eapply age_safe; eauto.
-
  induction k; try discriminate.
 + simpl in H2. apply IHk in H2. eapply jsafeN_local_step. constructor. intros. eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop1.
    intros.
    eapply age_safe; eauto.
    eapply jsafeN_local_step. apply step_skip_loop2.
    intros.
    eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop2.
    intros.
    eapply age_safe; eauto.
    eapply jsafeN_local_step. apply step_skip_loop2.
    intros.
    eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_skip_break_switch; auto.
    intros.
    eapply age_safe; eauto.
    eapply jsafeN_local_step. constructor.
    intros.
    eapply age_safe; eauto.
-
  induction k; try discriminate.
 + simpl in H2. apply IHk in H2. eapply jsafeN_local_step. constructor. intros. eapply age_safe; eauto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop1.
    intros.
    eapply age_safe; eauto.
    change (level (m_phi jm)) with (level jm) in H0.
    destruct (level jm). constructor.
    inv H0; [ | discriminate | contradiction].
    destruct H4.
    inv H0.
    eapply jsafeN_step.  split. econstructor; try eassumption.
    hnf; auto. auto. auto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. apply step_break_loop2.
    intros.
    eapply age_safe; eauto.
    change (level (m_phi jm)) with (level jm) in H0.
    destruct (level jm). constructor.
    inv H0; [ | discriminate | contradiction].
    destruct H4.
    inv H0.
    eapply jsafeN_step.  split. econstructor; try eassumption.
    hnf; auto. auto. auto.
 + simpl in H2. inv H2. clear IHk.
    eapply jsafeN_local_step. econstructor; auto. 
    intros.
    eapply age_safe; eauto.
    change (level (m_phi jm)) with (level jm) in H0.
    destruct (level jm). constructor.
    inv H0; [ | discriminate | contradiction].
    destruct H4.
    inv H0.
    eapply jsafeN_step.  split. econstructor; try eassumption.
    hnf; auto. auto. auto.
Qed.

Lemma semax_continue:
   forall Delta Q,        semax Espec Delta (RA_continue Q) Scontinue Q.
Proof.
 intros.
 rewrite semax_unfold; intros.  clear Prog_OK. rename w into n.
 intros te ve w ?.
 specialize (H0 EK_continue None te ve w H1).
 simpl exit_cont in H0.
 clear n H1.
 remember ((construct_rho (filter_genv psi) ve te)) as rho.
 revert w H0.
apply imp_derives; auto.
apply andp_derives; auto.
repeat intro.
  rewrite proj_frame_ret_assert. simpl proj_ret_assert; simpl seplog.sepcon.
rewrite sepcon_comm.
eapply andp_derives; try apply H0; auto.
normalize.
apply own.bupd_mono.
intros ???? Hora ???.
specialize (H0 ora jm Hora H1 H2 LW). 
subst a.
destruct (continue_cont k) eqn:?H; try contradiction.
-
 rename c into k'.
 revert k' H2 H0.
 induction k; simpl; intros; try discriminate.
 +
  eapply jsafeN_local_step. constructor. intros.
  eapply age_safe; try eassumption.
  eapply IHk; eauto.
 +
  inv H2.
  eapply jsafeN_local_step. apply step_skip_or_continue_loop1; auto. intros.
  eapply age_safe; try eassumption.
 +
  eapply jsafeN_local_step. apply step_continue_switch. intros.
  eapply age_safe; try eassumption.
  eapply IHk; eauto.
-
  elimtype False; clear - H2.
  revert c o H2; induction k; simpl; intros; try discriminate; eauto.
Qed.

End extensions.
