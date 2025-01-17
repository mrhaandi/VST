Require Import VST.msl.msl_standard.
Require Import VST.veric.Clight_base.
Require Import VST.veric.compcert_rmaps.
Require Import VST.veric.Clight_lemmas.
Require Import VST.veric.tycontext.
Require Import VST.veric.expr2.
Require Import VST.veric.Clight_Cop2.
Require Import VST.veric.binop_lemmas2.
Require Import VST.veric.binop_lemmas3.

Require Import VST.veric.juicy_mem.
Import Cop.
Import Cop2.
Import Clight_Cop2.
Import compcert.lib.Maps.

Lemma denote_tc_test_eq_Vint_l: forall m i v,
  (denote_tc_test_eq (Vint i) v) m ->
  i = Int.zero.
Proof.
  intros.
  unfold denote_tc_test_eq in H; simpl in H.
  destruct Archi.ptr64, v; try solve [inv H]; simpl in H; tauto.
Qed.

Lemma denote_tc_test_eq_Vint_r: forall m i v,
  (denote_tc_test_eq v (Vint i)) m ->
  i = Int.zero.
Proof.
  intros.
  unfold denote_tc_test_eq in H; simpl in H.
  destruct Archi.ptr64, v; try solve [inv H]; simpl in H; tauto.
Qed.


Lemma sameblock_eq_block:
 forall p q r s, 
  is_true (sameblock (Vptr p r) (Vptr q s)) -> p=q.
Proof.
 simpl; intros. destruct (peq p q); auto. inv H.
Qed.

Lemma denote_tc_test_eq_Vint_l': forall m i v,
  (denote_tc_test_eq (Vint i) v) m ->
  Int.eq i Int.zero = true.
Proof.
  intros.
  unfold denote_tc_test_eq in H; simpl in H.
  destruct v; try solve [inv H]; destruct Archi.ptr64; try solve [inv H];
   simpl in H; destruct H; subst;
   apply Int.eq_true.
Qed.

Lemma denote_tc_test_eq_Vint_r': forall m i v,
  (denote_tc_test_eq v (Vint i)) m ->
  Int.eq i Int.zero = true.
Proof.
  intros.
  unfold denote_tc_test_eq in H; simpl in H.
  destruct v; try solve [inv H];  destruct Archi.ptr64; try solve [inv H];
  simpl in H; destruct H; subst;
   apply Int.eq_true.
Qed.

Lemma denote_tc_test_eq_Vlong_l': forall m i v,
  (denote_tc_test_eq (Vlong i) v) m ->
  Int64.eq i Int64.zero = true.
Proof.
  intros.
  unfold denote_tc_test_eq in H; simpl in H.
  destruct v; try solve [inv H]; destruct Archi.ptr64; try solve [inv H];
   simpl in H; destruct H; subst;
   try apply Int.eq_true; apply Int64.eq_true.
Qed.

Lemma denote_tc_test_eq_Vlong_r': forall m i v,
  (denote_tc_test_eq v (Vlong i)) m ->
  Int64.eq i Int64.zero = true.
Proof.
  intros.
  unfold denote_tc_test_eq in H; simpl in H.
  destruct v; try solve [inv H];  destruct Archi.ptr64; try solve [inv H];
  simpl in H; destruct H; subst;
   try apply Int.eq_true; apply Int64.eq_true.
Qed.

Lemma denote_tc_test_order_eqblock:
  forall phi b0 i0 b i,
   app_pred (denote_tc_test_order (Vptr b0 i0) (Vptr b i)) phi ->
     b0 = b.
Proof.
intros.
unfold denote_tc_test_order in H; simpl in H.
unfold test_order_ptrs in H.
simpl in H. destruct (peq b0 b); auto. contradiction H.
Qed.

Lemma valid_pointer_dry:
  forall b ofs d m, app_pred (valid_pointer' (Vptr b ofs) d) (m_phi m) ->
           Mem.valid_pointer (m_dry m) b (Ptrofs.unsigned ofs + d) = true.
Proof.
intros.
simpl in H.
destruct (m_phi m @ (b, Ptrofs.unsigned ofs + d)) eqn:?H; try contradiction.
*
pose proof (juicy_mem_access m (b, Ptrofs.unsigned ofs + d)).
rewrite H0 in H1.
unfold access_at in H1.
unfold perm_of_res in H1.
simpl in H1. clear H0.
rewrite if_false in H1.
assert (exists x, (Mem.mem_access (m_dry m)) !! b (Ptrofs.unsigned ofs + d) Cur = Some x).
destruct ((Mem.mem_access (m_dry m)) !! b (Ptrofs.unsigned ofs + d) Cur); inv H1; eauto.
destruct H0.
apply perm_order'_dec_fiddle with x.
auto.
intro; subst sh. apply H; auto.
*
subst.
pose proof (juicy_mem_access m (b, Ptrofs.unsigned ofs + d)).
rewrite H0 in H1.
unfold access_at in H1.
unfold perm_of_res in H1.
simpl in H1. clear H0 H.
unfold Mem.valid_pointer.
unfold Mem.perm_dec.
destruct k.
+
assert (exists x, (Mem.mem_access (m_dry m)) !! b (Ptrofs.unsigned ofs + d) Cur = Some x).
rewrite H1. unfold perm_of_sh. repeat if_tac; try contradiction; eauto.
destruct H as [x H]; apply perm_order'_dec_fiddle with x; auto.
+
assert (exists x, (Mem.mem_access (m_dry m)) !! b (Ptrofs.unsigned ofs + d) Cur = Some x).
rewrite H1. unfold perm_of_sh. repeat if_tac; try contradiction; eauto.
destruct H as [x H]; apply perm_order'_dec_fiddle with x; auto.
+
assert (exists x, (Mem.mem_access (m_dry m)) !! b (Ptrofs.unsigned ofs + d) Cur = Some x).
rewrite H1. unfold perm_of_sh. repeat if_tac; try contradiction; eauto.
destruct H as [x H]; apply perm_order'_dec_fiddle with x; auto.
Qed.

Lemma weak_valid_pointer_dry:
  forall b ofs m, app_pred (weak_valid_pointer (Vptr b ofs)) (m_phi m) ->
           (Mem.valid_pointer (m_dry m) b (Ptrofs.unsigned ofs)
           || Mem.valid_pointer (m_dry m) b (Ptrofs.unsigned ofs - 1))%bool = true.
Proof.
intros.
rewrite orb_true_iff.
destruct H; [left  | right].
rewrite <- (Z.add_0_r (Ptrofs.unsigned ofs)).
apply valid_pointer_dry; auto.
rewrite <- Z.add_opp_r.
apply valid_pointer_dry; auto.
Qed.

Lemma test_eq_relate':
  forall v1 v2 op m
    (OP: op = Ceq \/ op = Cne),
     (denote_tc_test_eq v1 v2) (m_phi m) ->
     cmp_ptr (m_dry m) op v1 v2 = 
     Some (force_val (sem_cmp_pp op v1 v2)).
Proof.
intros.
unfold cmp_ptr, sem_cmp_pp.
unfold denote_tc_test_eq in H.
 destruct v1; try contradiction; auto;
 destruct v2; try contradiction; auto.
*
 simpl.
 destruct Archi.ptr64; try contradiction.
 destruct H.  hnf in H. subst i; rewrite ?Int.eq_true, ?Int64.eq_true. simpl.
 apply weak_valid_pointer_dry in H0.
 rewrite H0.
 destruct OP; subst; simpl; auto.
*
 simpl.
 destruct Archi.ptr64; try contradiction.
 destruct H.  hnf in H. subst; rewrite ?Int.eq_true, ?Int64.eq_true. simpl.
 apply weak_valid_pointer_dry in H0.
 rewrite H0.
 destruct OP; subst; simpl; auto.
*
 simpl.
 unfold test_eq_ptrs in *.
 unfold sameblock in H.
 destruct (peq b b0);
  simpl proj_sumbool in H; cbv iota in H;
 [rewrite !if_true by auto | rewrite !if_false by auto].
 destruct H.
 apply weak_valid_pointer_dry in H.
 apply weak_valid_pointer_dry in H0.
 rewrite H. rewrite H0.
 simpl.
 reflexivity.
 destruct H.
 apply valid_pointer_dry in H.
 apply valid_pointer_dry in H0.
 rewrite Z.add_0_r in H,H0.
 rewrite H. rewrite H0.
 destruct OP; subst;  reflexivity.
Qed.

Lemma sem_cast_relate:
 forall i sz si a si' a' m,
  Cop.sem_cast (Vint i) (Tint sz si a) (Tint I32 si' a') m =
 sem_cast (Tint sz si a)  (Tint I32 si' a') (Vint i).
Proof.
intros.
reflexivity.
Qed.
Lemma sem_cast_int_lemma:
 forall sz si a si' a' i, 
  sem_cast (Tint sz si a)  (Tint I32 si' a') (Vint i) = Some (Vint i).
Proof.
intros.
unfold sem_cast, classify_cast, tint, sem_cast_pointer.
auto.
Qed.

Lemma sem_cast_relate_int_long:
 forall i sz si a si' a' m,
  Cop.sem_cast (Vint i) (Tint sz si a) (Tlong si' a') m =
 sem_cast (Tint sz si a)  (Tlong si' a') (Vint i).
Proof.
intros.
reflexivity.
Qed.

Lemma sem_cast_relate_long:
 forall i si a si' a' m,
  Cop.sem_cast (Vlong i) (Tlong si a) (Tlong si' a') m =
 sem_cast (Tlong si a)  (Tlong si' a') (Vlong i).
Proof.
intros.
reflexivity.
Qed.

Lemma sem_cast_int_long_lemma:
 forall sz si a si' a' i, 
  sem_cast (Tint sz si a)  (Tlong si' a') (Vint i) = Some (Vlong (cast_int_long si i)).
Proof.
intros.
unfold sem_cast, classify_cast, tint, sem_cast_pointer, sem_cast_i2l.
auto.
Qed.
Lemma sem_cast_long_lemma:
 forall si a si' a' i, 
  sem_cast (Tlong si a)  (Tlong si' a') (Vlong i) = Some (Vlong i).
Proof.
intros.
unfold sem_cast, classify_cast, tint, sem_cast_pointer, sem_cast_i2l.
auto.
Qed.

Lemma denote_tc_test_eq_xx:
 forall v si i phi,
 app_pred (denote_tc_test_eq v (Vint i)) phi ->
 app_pred (denote_tc_test_eq v (Vptrofs (ptrofs_of_int si i))) phi.
Proof.
intros.
unfold denote_tc_test_eq in *.
destruct v; try contradiction;
unfold Vptrofs, ptrofs_of_int; simpl;
destruct Archi.ptr64; try contradiction;
destruct H; hnf in *; subst; destruct si; split; hnf; auto.
Qed.

Lemma denote_tc_test_eq_yy:
 forall v si i phi,
 app_pred (denote_tc_test_eq (Vint i) v) phi ->
 app_pred (denote_tc_test_eq (Vptrofs (ptrofs_of_int si i)) v) phi.
Proof.
intros.
unfold denote_tc_test_eq in *.
destruct v; try contradiction;
unfold Vptrofs, ptrofs_of_int; simpl;
destruct Archi.ptr64; try contradiction;
destruct H; hnf in *; subst; destruct si; split; hnf; auto.
Qed.

Lemma sem_cast_long_intptr_lemma:
 forall si a i,
  force_val1 (sem_cast (Tlong si a) size_t) (Vlong i)
 = Vptrofs (Ptrofs.of_int64 i).
Proof.
intros.
 unfold Vptrofs, size_t, sem_cast, classify_cast, sem_cast_pointer.
 destruct Archi.ptr64 eqn:Hp.
 simpl. rewrite Ptrofs.to_int64_of_int64; auto.
 simpl.
 f_equal.
 rewrite Ptrofs_to_of64_lemma; auto.
Qed.

Lemma test_order_relate':
  forall v1 v2 op m,
     (denote_tc_test_order v1 v2) (m_phi m) ->
   cmp_ptr (m_dry m) op v1 v2 = Some (force_val (sem_cmp_pp op v1 v2)).
Proof.
  intros.
  unfold denote_tc_test_order in H.
  destruct v1; try contradiction; auto;
  destruct v2; try contradiction; auto.
  unfold cmp_ptr, sem_cmp_pp; simpl.
  unfold test_order_ptrs in *.
  unfold sameblock in H.
  destruct (peq b b0);
  simpl proj_sumbool in H; cbv iota in H;
    [rewrite !if_true by auto | rewrite !if_false by auto].
  + destruct H.
    apply weak_valid_pointer_dry in H.
    apply weak_valid_pointer_dry in H0.
    rewrite H. rewrite H0.
    simpl.
    reflexivity.
  + inv H.
Qed.

Lemma sem_cast_int_intptr_lemma:
 forall sz si a i,
  force_val1 (sem_cast (Tint sz si a) size_t) (Vint i)
 = Vptrofs (ptrofs_of_int si i).
Proof.
intros.
 unfold Vptrofs, size_t, sem_cast, classify_cast, sem_cast_pointer.
 destruct Archi.ptr64 eqn:Hp.
+ simpl. unfold cast_int_long, ptrofs_of_int.
 destruct si; auto.
 unfold Ptrofs.to_int64.
 unfold Ptrofs.of_ints.
 f_equal.
 rewrite (Ptrofs.agree64_repr Hp), Int64.repr_unsigned. auto.
 f_equal.
 unfold Ptrofs.to_int64.
 unfold Ptrofs.of_intu. unfold Ptrofs.of_int.
 rewrite Ptrofs.unsigned_repr; auto.
 pose proof (Int.unsigned_range i).
 pose proof (Ptrofs.modulus_eq64 Hp).
 unfold Ptrofs.max_unsigned.
 rewrite H0.
 assert (Int.modulus < Int64.modulus) by (compute; auto).
 lia.
+ try ( (* Archi.ptr64=false *)
  simpl; f_equal;
  unfold Ptrofs.to_int, ptrofs_of_int, Ptrofs.of_ints, Ptrofs.of_intu, Ptrofs.of_int;
  destruct si;
  rewrite ?(Ptrofs.agree32_repr Hp),
    ?Int.repr_unsigned, ?Int.repr_signed; auto).
Qed.

Lemma test_eq_fiddle_signed_xx:
 forall si si' v i phi, 
app_pred (denote_tc_test_eq v (Vptrofs (ptrofs_of_int si i))) phi ->
app_pred (denote_tc_test_eq v (Vptrofs (ptrofs_of_int si' i))) phi.
Proof.
intros.
unfold denote_tc_test_eq in *.
unfold Vptrofs, ptrofs_of_int in *.
destruct v; try contradiction;
destruct Archi.ptr64 eqn:Hp; try contradiction; subst.
-
destruct H; split; auto.
clear H.
hnf in H0|-*.
destruct si; auto.
*
unfold Ptrofs.of_ints in *.
unfold Ptrofs.to_int, Ptrofs.to_int64 in *.
rewrite ?Ptrofs.agree32_repr, ?Ptrofs.agree64_repr,
             ?Int.repr_unsigned, ?Int64.repr_unsigned in H0 by auto.
assert (i=Int.zero)
  by first [apply Int64repr_Intsigned_zero; solve [auto]
              | rewrite <- (Int.repr_signed i); auto].
subst i.
destruct si'; auto.
*
destruct si'; auto.
unfold Ptrofs.of_intu in H0.
try ( (* Archi.ptr64=false case *)
 rewrite Ptrofs.to_int_of_int in H0 by auto;
 subst;
 unfold Ptrofs.of_ints;
 rewrite Int.signed_zero;
 unfold Ptrofs.to_int;
 rewrite Ptrofs.unsigned_repr; [reflexivity |];
 unfold Ptrofs.max_unsigned; rewrite (Ptrofs.modulus_eq32 Hp);
 compute; split; congruence);
(* Archi.ptr64=true case *)
try (unfold Ptrofs.of_int, Ptrofs.to_int64 in H0;
rewrite Ptrofs.unsigned_repr in H0;
 [apply Int64repr_Intunsigned_zero in H0; subst; reflexivity
 | pose proof (Int.unsigned_range i);
   destruct H; split; auto;
   assert (Int.modulus < Ptrofs.max_unsigned)
     by (unfold Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize; rewrite Hp; compute; auto);
    lia]).
-
destruct H.
split; auto.
hnf in H|-*. clear H0.
destruct si, si'; auto.
*
unfold Ptrofs.of_ints, Ptrofs.of_intu in *.
unfold Ptrofs.to_int64 in H.
rewrite (Ptrofs.agree64_repr Hp) in H.
rewrite Int64.repr_unsigned in H.
apply Int64repr_Intsigned_zero in H. subst.
reflexivity.
*
unfold Ptrofs.of_ints, Ptrofs.of_intu in *.
unfold Ptrofs.to_int64, Ptrofs.of_int in H.
rewrite (Ptrofs.agree64_repr Hp) in H.
rewrite Int64.repr_unsigned in H.
apply Int64repr_Intunsigned_zero in H. subst.
reflexivity.
-
destruct H.
split; auto.
hnf in H|-*. clear H0.
destruct si, si'; auto;
unfold Ptrofs.to_int, Ptrofs.of_intu, Ptrofs.of_ints, Ptrofs.of_int in *;
rewrite (Ptrofs.agree32_repr Hp) in H;
rewrite (Ptrofs.agree32_repr Hp);
rewrite Int.repr_unsigned in *;
rewrite Int.repr_signed in *; rewrite Int.repr_unsigned in *; auto.
Qed.

Lemma test_eq_fiddle_signed_yy:
 forall si si' v i phi, 
app_pred (denote_tc_test_eq (Vptrofs (ptrofs_of_int si i)) v) phi ->
app_pred (denote_tc_test_eq (Vptrofs (ptrofs_of_int si' i)) v) phi.
Proof.
intros.
unfold denote_tc_test_eq in *.
unfold Vptrofs, ptrofs_of_int in *.
destruct v; try contradiction;
destruct Archi.ptr64 eqn:Hp; try contradiction; subst.
-
destruct H; split; auto.
clear H0.
hnf in H|-*.
destruct si; auto.
*
unfold Ptrofs.of_ints in *.
unfold Ptrofs.to_int, Ptrofs.to_int64 in *.
rewrite ?Ptrofs.agree32_repr, ?Ptrofs.agree64_repr,
             ?Int.repr_unsigned, ?Int64.repr_unsigned in H by auto.
assert (i=Int.zero)
  by first [apply Int64repr_Intsigned_zero; solve [auto]
              | rewrite <- (Int.repr_signed i); auto].
subst i.
destruct si'; auto.
*
destruct si'; auto.
unfold Ptrofs.of_intu in H.
try ( (* Archi.ptr64=false case *)
 rewrite Ptrofs.to_int_of_int in H by auto;
 subst;
 unfold Ptrofs.of_ints;
 rewrite Int.signed_zero;
 unfold Ptrofs.to_int;
 rewrite Ptrofs.unsigned_repr; [reflexivity |];
 unfold Ptrofs.max_unsigned; rewrite (Ptrofs.modulus_eq32 Hp);
 compute; split; congruence);
(* Archi.ptr64=true case *)
try (unfold Ptrofs.of_int, Ptrofs.to_int64 in H;
rewrite Ptrofs.unsigned_repr in H;
 [apply Int64repr_Intunsigned_zero in H; subst; reflexivity
 | pose proof (Int.unsigned_range i);
   destruct H; split; auto;
   assert (Int.modulus < Ptrofs.max_unsigned)
     by (unfold Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize; rewrite Hp; compute; auto);
    lia]).
-
destruct H.
split; auto.
hnf in H|-*. clear H0.
destruct si, si'; auto.
*
unfold Ptrofs.of_ints, Ptrofs.of_intu in *.
unfold Ptrofs.to_int64 in H.
rewrite (Ptrofs.agree64_repr Hp) in H.
rewrite Int64.repr_unsigned in H.
apply Int64repr_Intsigned_zero in H. subst.
reflexivity.
*
unfold Ptrofs.of_ints, Ptrofs.of_intu in *.
unfold Ptrofs.to_int64, Ptrofs.of_int in H.
rewrite (Ptrofs.agree64_repr Hp) in H.
rewrite Int64.repr_unsigned in H.
apply Int64repr_Intunsigned_zero in H. subst.
reflexivity.
-
destruct H.
split; auto.
hnf in H|-*. clear H0.
destruct si, si'; auto;
unfold Ptrofs.to_int, Ptrofs.of_intu, Ptrofs.of_ints, Ptrofs.of_int in *;
rewrite (Ptrofs.agree32_repr Hp) in H;
rewrite (Ptrofs.agree32_repr Hp);
rewrite Int.repr_unsigned in *;
rewrite Int.repr_signed in *; rewrite Int.repr_unsigned in *; auto.
Qed.


Lemma test_order_fiddle_signed_xx:
 forall si si' v i phi, 
app_pred (denote_tc_test_order v (Vptrofs (ptrofs_of_int si i))) phi ->
app_pred (denote_tc_test_order v (Vptrofs (ptrofs_of_int si' i))) phi.
Proof.
intros.
unfold denote_tc_test_order in *.
unfold Vptrofs, ptrofs_of_int in *.
destruct v; try contradiction;
destruct Archi.ptr64 eqn:Hp; try contradiction; subst.
destruct H; split; auto.
clear H.
hnf in H0|-*.
destruct si, si'; auto;
try ( (* Archi.ptr64 = false *)
unfold Ptrofs.to_int, Ptrofs.of_intu, Ptrofs.of_ints, Ptrofs.of_int in *;
rewrite (Ptrofs.agree32_repr Hp) in H0;
rewrite (Ptrofs.agree32_repr Hp);
rewrite Int.repr_unsigned in *;
rewrite Int.repr_signed in *; rewrite Int.repr_unsigned in *; auto);
try ((* Archi.ptr64 = true *)
  unfold Ptrofs.to_int, Ptrofs.of_intu, Ptrofs.of_ints, Ptrofs.of_int in *;
  unfold Ptrofs.to_int64 in *;
  rewrite Ptrofs.unsigned_repr_eq in *;
  change Ptrofs.modulus with Int64.modulus in *;
  rewrite <- Int64.unsigned_repr_eq in *;
  rewrite Int64.repr_unsigned in *;
  first [apply Int64repr_Intsigned_zero in H0 
          |apply Int64repr_Intunsigned_zero in H0];
  subst i; reflexivity).
Qed.

Lemma test_order_fiddle_signed_yy:
 forall si si' v i phi, 
app_pred (denote_tc_test_order (Vptrofs (ptrofs_of_int si i)) v) phi ->
app_pred (denote_tc_test_order (Vptrofs (ptrofs_of_int si' i)) v) phi.
Proof.
intros.
unfold denote_tc_test_order in *.
unfold Vptrofs, ptrofs_of_int in *.
destruct v; try contradiction;
destruct Archi.ptr64 eqn:Hp; try contradiction; subst.
destruct H; split; auto.
clear H0.
hnf in H|-*.
destruct si, si'; auto;
try ( (* Archi.ptr64 = false *)
unfold Ptrofs.to_int, Ptrofs.of_intu, Ptrofs.of_ints, Ptrofs.of_int in *;
rewrite (Ptrofs.agree32_repr Hp) in H;
rewrite (Ptrofs.agree32_repr Hp);
rewrite Int.repr_unsigned in *;
rewrite Int.repr_signed in *; rewrite Int.repr_unsigned in *; auto);
try ((* Archi.ptr64 = true *)
  unfold Ptrofs.to_int, Ptrofs.of_intu, Ptrofs.of_ints, Ptrofs.of_int in *;
  unfold Ptrofs.to_int64 in *;
  rewrite Ptrofs.unsigned_repr_eq in *;
  change Ptrofs.modulus with Int64.modulus in *;
  rewrite <- Int64.unsigned_repr_eq in *;
  rewrite Int64.repr_unsigned in *;
  first [apply Int64repr_Intsigned_zero in H 
          |apply Int64repr_Intunsigned_zero in H];
  subst i; reflexivity).
Qed.

Lemma denote_tc_nonzero_e':
 forall i m, app_pred (denote_tc_nonzero (Vint i)) m -> Int.eq i Int.zero = false.
Proof.
simpl; intros; apply Int.eq_false; auto.
Qed.

Lemma denote_tc_nodivover_e':
 forall i j m, app_pred (denote_tc_nodivover (Vint i) (Vint j)) m ->
   Int.eq i (Int.repr Int.min_signed) && Int.eq j Int.mone = false.
Proof.
simpl; intros.
rewrite andb_false_iff.
apply Classical_Prop.not_and_or in H.
destruct H; [left|right]; apply Int.eq_false; auto.
Qed.

Lemma denote_tc_nonzero_e64':
 forall i m, app_pred (denote_tc_nonzero (Vlong i)) m -> Int64.eq i Int64.zero = false.
Proof.
simpl; intros; apply Int64.eq_false; auto.
Qed.

Lemma denote_tc_nodivover_e64_ll':
 forall i j m, app_pred (denote_tc_nodivover (Vlong i) (Vlong j)) m ->
   Int64.eq i (Int64.repr Int64.min_signed) && Int64.eq j Int64.mone = false.
Proof.
simpl; intros.
rewrite andb_false_iff.
apply Classical_Prop.not_and_or in H.
destruct H; [left|right]; apply Int64.eq_false; auto.
Qed.

Lemma denote_tc_nodivover_e64_il':
 forall s i j,
   Int64.eq (cast_int_long s i) (Int64.repr Int64.min_signed) && Int64.eq j Int64.mone = false.
Proof.
intros.
assert (app_pred (denote_tc_nodivover (Vint i) (Vlong j)) (empty_rmap O)) by apply I.
rewrite andb_false_iff.
destruct (Classical_Prop.not_and_or _ _ (denote_tc_nodivover_e64_il s _ _ _ H)); [left|right];
 apply Int64.eq_false; auto.
Qed.

Lemma denote_tc_nodivover_e64_li':
 forall s i j m, app_pred (denote_tc_nodivover (Vlong i) (Vint j)) m ->
   Int64.eq i (Int64.repr Int64.min_signed) && Int64.eq (cast_int_long s j) Int64.mone = false.
Proof.
intros.
rewrite andb_false_iff.
destruct (Classical_Prop.not_and_or _ _ (denote_tc_nodivover_e64_li s _ _ _ H)); [left|right];
 apply Int64.eq_false; auto.
Qed.

Lemma Int64_eq_repr_signed32_nonzero':
  forall i, Int.eq i Int.zero = false ->
             Int64.eq (Int64.repr (Int.signed i)) Int64.zero = false.
Proof.
intros.
pose proof (Int.eq_spec i Int.zero). rewrite H in H0. clear H.
pose proof (Int64_eq_repr_signed32_nonzero i H0).
apply Int64.eq_false; auto.
Qed.

Lemma Int64_eq_repr_unsigned32_nonzero':
  forall i, Int.eq i Int.zero = false ->
             Int64.eq (Int64.repr (Int.unsigned i)) Int64.zero = false.
Proof.
intros.
pose proof (Int.eq_spec i Int.zero). rewrite H in H0. clear H.
pose proof (Int64_eq_repr_unsigned32_nonzero i H0).
apply Int64.eq_false; auto.
Qed.

Lemma Int64_eq_repr_int_nonzero':
  forall s i, Int.eq i Int.zero = false ->
    Int64.eq (cast_int_long s i) Int64.zero = false.
Proof.
  intros.
pose proof (Int.eq_spec i Int.zero). rewrite H in H0. clear H.
pose proof (Int64_eq_repr_int_nonzero s i H0).
apply Int64.eq_false; auto.
Qed.

Lemma denote_tc_igt_e':
  forall m i j, app_pred (denote_tc_igt j (Vint i)) m ->
        Int.ltu i j = true.
Proof.
intros. unfold Int.ltu. rewrite if_true by (apply (denote_tc_igt_e _ _ _ H)); auto.
Qed.

Lemma denote_tc_lgt_e':
  forall m i j, app_pred (denote_tc_lgt j (Vlong i)) m ->
        Int64.ltu i j = true.
Proof.
intros. unfold Int64.ltu. rewrite if_true by (apply (denote_tc_lgt_e _ _ _ H)); auto.
Qed.

Lemma denote_tc_iszero_long_e':
 forall m i,
  app_pred (denote_tc_iszero (Vlong i)) m ->
  Int64.eq (Int64.repr (Int64.unsigned i)) Int64.zero = true.
Proof.
intros.
hnf in H.
pose proof (Int64.eq_spec i Int64.zero).
destruct (Int64.eq i Int64.zero);
  try contradiction.
subst; reflexivity.
Qed.


Lemma sem_binary_operation_stable: 
  forall (cs1: compspecs) cs2 
   (CSUB: forall id co, (@cenv_cs cs1)!id = Some co -> cs2!id = Some co)
   b v1 e1 v2 e2 phi m v t rho,
   app_pred
       (@denote_tc_assert cs1 (@isBinOpResultType cs1 b e1 e2 t) rho) phi ->
   sem_binary_operation  (@cenv_cs cs1) b v1 (typeof e1) v2 (typeof e2) m = Some v ->
   sem_binary_operation cs2 b v1 (typeof e1) v2 (typeof e2) m = Some v.
Proof.
intros.
assert (CONSIST:= @cenv_consistent cs1).
rewrite den_isBinOpR in H.
simpl in H.
forget (op_result_type (Ebinop b e1 e2 t)) as err.
forget (arg_type (Ebinop b e1 e2 t)) as err0.
destruct b; simpl in *; auto;
unfold Cop.sem_add, Cop.sem_sub in *;
rewrite ?classify_add_eq, ?classify_sub_eq in *;
match goal with |- match ?A with _ => _ end = _ => destruct A eqn:?HC end; auto;
destruct (typeof e1)  as [ | [ | | | ] [ | ] | [ | ] | [ | ] | | | | | ]; try discriminate HC;
destruct (typeof e2)  as [ | [ | | | ] [ | ] | [ | ] | [ | ] | | | | | ]; try discriminate HC;
simpl in *; decompose [and] H; clear H;
repeat match goal with H: app_pred (denote_tc_assert (tc_bool _ _) _) _ |- _ =>
    apply tc_bool_e in H 
end;
unfold Cop.sem_add_ptr_int, Cop.sem_add_ptr_long in *;
simpl in *;
rewrite <- (sizeof_stable _ _ CSUB) in H0 by auto; auto.
Qed.

Lemma eq_block_lem':
 forall a, eq_block a a = left (eq_refl a).
Proof.
intros.
destruct (eq_block a). f_equal. apply proof_irr.
congruence.
Qed.

Lemma isptr_e:
 forall {v}, isptr v -> exists b ofs, v = Vptr b ofs.
Proof. destruct v; try contradiction; eauto. Qed.

Lemma is_int_e': forall {sz sg v}, 
  is_int sz sg v -> exists i, v = Vint i.
Proof. destruct v; try contradiction; eauto. Qed.

Lemma is_long_e: forall {v}, is_long v -> exists i, v = Vlong i.
Proof. destruct v; try contradiction; eauto. Qed.

Lemma is_single_e: forall {v}, is_single v -> exists f, v = Vsingle f.
Proof. destruct v; try contradiction; eauto. Qed.

Lemma is_float_e: forall {v}, is_float v -> exists f, v = Vfloat f.
Proof. destruct v; try contradiction; eauto. Qed.

Lemma eval_binop_relate':
 forall {CS: compspecs} (ge: genv) te ve rho b e1 e2 t m
    (Hcenv: cenv_sub (@cenv_cs CS) (genv_cenv ge))
    (H1: Clight.eval_expr ge ve te (m_dry m) e1 (eval_expr e1 rho))
    (H2: Clight.eval_expr ge ve te (m_dry m) e2 (eval_expr e2 rho))
    (H3: app_pred (denote_tc_assert (isBinOpResultType b e1 e2 t) rho) (m_phi m))
    (TC1 : tc_val (typeof e1) (eval_expr e1 rho))
    (TC2 : tc_val (typeof e2) (eval_expr e2 rho)),
Clight.eval_expr ge ve te (m_dry m) (Ebinop b e1 e2 t)
  (force_val2 (sem_binary_operation' b (typeof e1) (typeof e2))
     (eval_expr e1 rho) (eval_expr e2 rho)).
Proof.
intros.
econstructor; try eassumption; clear H1 H2.
assert (sem_binary_operation (@cenv_cs CS) b (@eval_expr CS e1 rho) 
  (typeof e1) (@eval_expr CS e2 rho) (typeof e2) (m_dry m) =
@Some val
  (force_val2 (@sem_binary_operation' CS b (typeof e1) (typeof e2))
     (@eval_expr CS e1 rho) (@eval_expr CS e2 rho))).
2:{
eapply sem_binary_operation_stable; try eassumption.
clear - Hcenv.
hnf in Hcenv.
intros.
specialize (Hcenv id). hnf in Hcenv. rewrite H in Hcenv. auto.
}
clear Hcenv ge.
rewrite den_isBinOpR in H3.
simpl in H3.
forget (op_result_type (Ebinop b e1 e2 t)) as err.
forget (arg_type (Ebinop b e1 e2 t)) as err0.
cbv beta iota zeta delta [
  sem_binary_operation sem_binary_operation' 
   binarithType' 
 ] in *.
clear ve te.
destruct b;
repeat lazymatch type of H3 with
| context [classify_add'] => destruct (classify_add' (typeof e1) (typeof e2)) eqn:?C
| context [classify_sub'] => destruct (classify_sub' (typeof e1) (typeof e2)) eqn:?C
| context [classify_binarith'] => 
   destruct (classify_binarith' (typeof e1) (typeof e2)) eqn:?C; try destruct s
| context [classify_shift'] => destruct (classify_shift' (typeof e1) (typeof e2)) eqn:?C
| context [classify_cmp'] => destruct (classify_cmp' (typeof e1) (typeof e2)) eqn:?C
| _ => idtac
end;
simpl in H3; super_unfold_lift;
unfold tc_int_or_ptr_type in *;
repeat match goal with
 |  H: _ /\ _ |- _ => destruct H
 |  H: app_pred (denote_tc_assert (tc_bool _ _) _) _ |- _ =>
       apply tc_bool_e in H
end;
forget (eval_expr e1 rho) as v1;
forget (eval_expr e2 rho) as v2;
try clear rho;
try clear err err0;
repeat match goal with
 | H: negb (eqb_type ?A ?B) = true |- _ =>
             rewrite negb_true_iff in H; try rewrite H in *
 | H: eqb_type ?A ?B = true |- _ =>
             try rewrite H in *
end;
try rewrite <- ?classify_add_eq , <- ?classify_sub_eq, <- ?classify_cmp_eq, <- ?classify_binarith_eq in *;
 rewrite ?sem_cast_long_intptr_lemma in *;
 rewrite ?sem_cast_int_intptr_lemma in *;
  cbv beta iota zeta delta [
  sem_binary_operation sem_binary_operation' 
   Cop.sem_add sem_add Cop.sem_sub sem_sub Cop.sem_div
   Cop.sem_mod sem_mod Cop.sem_shl Cop.sem_shift 
   sem_shl sem_shift sem_add_ptr_long sem_add_ptr_int
   sem_add_long_ptr sem_add_int_ptr
   Cop.sem_shr sem_shr Cop.sem_cmp sem_cmp
   sem_cmp_pp sem_cmp_pl sem_cmp_lp 
   Cop.sem_binarith sem_binarith
   binarith_type 
   sem_shift_ii sem_shift_ll sem_shift_il sem_shift_li
    sem_sub_pp sem_sub_pi sem_sub_pl 
   force_val2 typeconv remove_attributes change_attributes
   sem_add_ptr_int force_val both_int both_long force_val2
    Cop.sem_add_ptr_int
 ];
 try rewrite C; try rewrite C0; try rewrite C1;
 repeat match goal with
            | H: complete_type _ _ = _ |- _ => rewrite H; clear H
            | H: eqb_type _ _ = _ |- _ => rewrite H
            end;
 try clear CS; try clear m;
 try change (Ctypes.sizeof ty) with (sizeof ty).
Time
all: try ( (
red in TC1,TC2;
destruct (typeof e1)  as [ | [ | | | ] [ | ] | [ | ] | [ | ] | | | | | ];
try discriminate C;
try solve [contradiction TC1];
destruct (typeof e2)  as [ | [ | | | ] [ | ] | [ | ] | [ | ] | | | | | ];
try solve [contradiction TC2];
try discriminate C; try discriminate C0;
repeat match goal with
 | H: typecheck_error _ |- _ => contradiction H
 | H: andb _ _ = true |- _ => rewrite andb_true_iff in H; destruct H
 | H: isptr ?A |- _ => destruct (isptr_e H) as [?b [?ofs ?]]; clear H; subst A
 | H: is_int _ _ ?A |- _ => destruct (is_int_e' H) as [?i ?]; clear H; subst A
 | H: is_long ?A |- _ =>  destruct (is_long_e H) as [?i ?]; clear H; subst A
 | H: is_single ?A |- _ => destruct (is_single_e H) as [?f ?]; clear H; subst A
 | H: is_float ?A |- _ => destruct (is_float_e H) as [?f ?]; clear H; subst A
 | H: is_true (sameblock _ _) |- _ => apply sameblock_eq_block in H; subst;
                                                         rewrite ?eq_block_lem'
 | H: is_numeric_type _ = true |- _  => inv H
 end;
 try simple apply eq_refl;
 rewrite ?sem_cast_long_intptr_lemma in *;
 rewrite ?sem_cast_int_intptr_lemma in *;
 rewrite ?sem_cast_relate, ?sem_cast_relate_long, ?sem_cast_relate_int_long;
 rewrite ?sem_cast_int_lemma, ?sem_cast_long_lemma, ?sem_cast_int_long_lemma;
 rewrite ?if_true by auto;
 rewrite ?sizeof_range_true by auto;
 erewrite ?denote_tc_nodivover_e' by eassumption;
 erewrite ?denote_tc_nonzero_e' by eassumption;
 rewrite ?cast_int_long_nonzero by (eapply denote_tc_nonzero_e'; eassumption);
 rewrite ?(proj2 (eqb_type_false _ _)) by auto 1;
 try reflexivity;
 try solve [simple apply test_eq_relate'; auto;
               try (apply denote_tc_test_eq_xx; assumption);
               try (apply denote_tc_test_eq_yy; assumption);
               try (eapply test_eq_fiddle_signed_xx; eassumption);
               try (eapply test_eq_fiddle_signed_yy; eassumption)];
 try solve [simple apply test_order_relate'; auto; 
               try (eapply test_order_fiddle_signed_xx; eassumption);
               try (eapply test_order_fiddle_signed_yy; eassumption)];
 erewrite ?(denote_tc_nodivover_e64_li' Signed) by eassumption;
 erewrite ?(denote_tc_nodivover_e64_il' Signed) by eassumption;
 erewrite ?(denote_tc_nodivover_e64_li' Unsigned) by eassumption;
 erewrite ?(denote_tc_nodivover_e64_il' Unsigned) by eassumption;
 erewrite ?denote_tc_nodivover_e64_ll' by eassumption;
 erewrite ?denote_tc_nonzero_e64' by eassumption;
 erewrite ?denote_tc_igt_e' by eassumption;
 erewrite ?denote_tc_lgt_e' by eassumption;
 erewrite ?denote_tc_test_eq_Vint_l' by eassumption;
 erewrite ?denote_tc_test_eq_Vint_r' by eassumption;
 erewrite ?denote_tc_test_eq_Vlong_l' by eassumption;
 erewrite ?denote_tc_test_eq_Vlong_r' by eassumption;
 reflexivity)).  (* 292 sec *)

Time Qed.  (* 31.5 sec *)
