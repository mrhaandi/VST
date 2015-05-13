Require Import floyd.base.
Require Import floyd.client_lemmas.
Require Import floyd.type_induction.
Require Import floyd.jmeq_lemmas.
Require Export floyd.zlist.
Require Export floyd.compact_prod_sum.
Require floyd.fieldlist.
Import floyd.fieldlist.fieldlist.
Require Import Coq.Logic.JMeq.

Definition 
map_map: forall {A B C : Type} (f : A -> B) (g : B -> C) (l : list A),
       map g (map f l) = map (fun x : A => g (f x)) l :=
fun (A B C : Type) (f : A -> B) (g : B -> C) (l : list A) =>
list_ind
  (fun l0 : list A => map g (map f l0) = map (fun x : A => g (f x)) l0)
  eq_refl
  (fun (a : A) (l0 : list A)
     (IHl : map g (map f l0) = map (fun x : A => g (f x)) l0) =>
   eq_ind_r
     (fun l1 : list C =>
      g (f a) :: l1 = g (f a) :: map (fun x : A => g (f x)) l0) eq_refl IHl)
  l.

(******************************************

Definition of reptype.

******************************************)

Notation sigTT P := (fun tv => match tv with existT t v => P t end).

Definition compact_prod_sigT_type {A} {P: A -> Type} (l: list (sigT P)): Type :=
  compact_prod (map (sigTT P) l).

Definition compact_prod_sigT_value: forall {A} {P: A -> Type} (l: list (sigT P)), compact_prod (map (sigTT P) l).
Proof.
  intros.
  destruct l as [| [t0 v0] l]; [exact tt |].
  revert t0 v0; induction l as [| [t v] l]; intros.
  + exact v0.
  + exact (v0, IHl t v).
Defined.

Definition compact_sum_sigT_type {A} {P: A -> Type} (l: list (sigT P)): Type :=
  compact_sum (map (sigTT P) l).

Definition compact_sum_sigT_value: forall {A} {P: A -> Type} (l: list (sigT P)), compact_sum (map (sigTT P) l).
Proof.
  intros.
  destruct l as [| [t0 v0] l]; [exact tt |].
  revert t0 v0; destruct l as [| [t v] l]; intros.
  + exact v0.
  + exact (inl v0).
Defined.

Definition compact_prod_map {X: Type} {F F0: X -> Type} (l: list X)
  (f: ListType (map (fun x => F x -> F0 x) l)): compact_prod (map F l) -> compact_prod (map F0 l).
Proof.
  intros.
  destruct l; [exact tt |].
  revert x f X0; induction l; intros; simpl in *.
  + inversion f; subst.
    exact (a X0).
  + remember ((F a -> F0 a) :: map (fun x0 : X => F x0 -> F0 x0) l) as L;
    inversion f; subst.
    exact (a0 (fst X0), IHl a b (snd X0)).
Defined.

Lemma compact_prod_map_nil: forall {X: Type} {F F0: X -> Type},
  @compact_prod_map X F F0 nil Nil tt = tt.
Proof.
  intros.
  reflexivity.
Qed.

Lemma compact_prod_map_single: forall {X: Type} {F F0: X -> Type} (x: X)
  (f: F x -> F0 x) (v: F x),
  compact_prod_map (x :: nil) (Cons f Nil) v = f v.
Proof.
  intros.
  reflexivity.
Qed.

Lemma compact_prod_map_cons: forall {X: Type} {F F0: X -> Type} (x x0: X) (l: list X)
  (f: F x -> F0 x) (fl: ListType (map (fun x => F x -> F0 x) (x0 :: l)))
  (v: F x) (vl: compact_prod (map F (x0 :: l))),
  compact_prod_map (x :: x0 :: l) (Cons f fl) (v, vl) = (f v, compact_prod_map _ fl vl).
Proof.
  intros.
  reflexivity.
Qed.

Definition compact_sum_map {X: Type} {F F0: X -> Type} (l: list X)
  (f: ListType (map (fun x => F x -> F0 x) l)): compact_sum (map F l) -> compact_sum (map F0 l).
Proof.
  intros.
  destruct l; [exact tt |].
  revert x f X0; induction l; intros; simpl in *.
  + inversion f; subst.
    exact (a X0).
  + remember ((F a -> F0 a) :: map (fun x0 : X => F x0 -> F0 x0) l) as L;
    inversion f; subst.
    exact match X0 with
          | inl X0_l => inl (a0 X0_l)
          | inr X0_r => inr (IHl a b X0_r)
          end.
Defined.

Lemma compact_sum_map_nil: forall {X: Type} {F F0: X -> Type},
  @compact_sum_map X F F0 nil Nil tt = tt.
Proof.
  intros.
  reflexivity.
Qed.

Lemma compact_sum_map_single: forall {X: Type} {F F0: X -> Type} (x: X)
  (f: F x -> F0 x) (v: F x),
  compact_sum_map (x :: nil) (Cons f Nil) v = f v.
Proof.
  intros.
  reflexivity.
Qed.

Lemma compact_sum_map_cons_inl: forall {X: Type} {F F0: X -> Type} (x x0: X) (l: list X)
  (f: F x -> F0 x) (fl: ListType (map (fun x => F x -> F0 x) (x0 :: l)))
  (v: F x),
  compact_sum_map (x :: x0 :: l) (Cons f fl) (inl v) = inl (f v).
Proof.
  intros.
  reflexivity.
Qed.

Lemma compact_sum_map_cons_inr: forall {X: Type} {F F0: X -> Type} (x x0: X) (l: list X)
  (f: F x -> F0 x) (fl: ListType (map (fun x => F x -> F0 x) (x0 :: l)))
  (vl: compact_sum (map F (x0 :: l))),
  compact_sum_map (x :: x0 :: l) (Cons f fl) (inr vl) = inr (compact_sum_map _ fl vl).
Proof.
  intros.
  reflexivity.
Qed.

Section CENV.

Context {cs: compspecs}.
Context {csl: compspecs_legal cs}.

Definition reptype_gen: type -> (sigT (fun x => x)) :=
  func_type (fun _ => (sigT (fun x => x)))
  (fun t =>
     if (type_is_by_value t)
     then existT (fun x => x) val Vundef
     else existT (fun x => x) unit tt)
  (fun t n a TV => match TV with existT T V =>
                     existT (fun x => x)
                      (@zlist T V (list_zlist T V) 0 n) (zl_default 0 n)
                   end)
  (fun id a TVs => existT (fun x => x) (compact_prod_sigT_type (decay TVs)) (compact_prod_sigT_value (decay TVs)))
  (fun id a TVs => existT (fun x => x) (compact_sum_sigT_type (decay TVs)) (compact_sum_sigT_value (decay TVs))).

Definition reptype t: Type := match reptype_gen t with existT t _ => t end.
Definition default_val t: reptype t :=
  match reptype_gen t as tv
    return match tv with existT t _ => t end
  with existT t v => v end.

Lemma reptype_gen_ind: forall t,
  reptype_gen t =
  match t with
  | Tarray t0 _ _ => match reptype_gen t0 with existT T V => existT (fun x => x) (list T) nil end
  | Tstruct id _ => existT (fun x => x)
                     (compact_prod_sigT_type (map reptype_gen (map (fun it => field_type (fst it) (co_members (get_co id))) (co_members (get_co id)))))
                     (compact_prod_sigT_value (map reptype_gen (map (fun it => field_type (fst it) (co_members (get_co id))) (co_members (get_co id)))))
  | Tunion id _ => existT (fun x => x)
                     (compact_sum_sigT_type (map reptype_gen (map (fun it => field_type (fst it) (co_members (get_co id))) (co_members (get_co id)))))
                     (compact_sum_sigT_value (map reptype_gen (map (fun it => field_type (fst it) (co_members (get_co id))) (co_members (get_co id)))))
  | _ => if (type_is_by_value t)
         then existT (fun x => x) val Vundef
         else existT (fun x => x) unit tt
  end.
Proof.
  intros.
  unfold reptype_gen at 1.
  rewrite func_type_ind.
  destruct t; auto.
  + rewrite decay_spec.
    rewrite map_map.
    reflexivity.
  + rewrite decay_spec.
    rewrite map_map.
    reflexivity.
Defined.

Definition reptype_structlist (m: members) := compact_prod (map (fun it => reptype (field_type (fst it) m)) m).
Definition reptype_unionlist (m: members) := compact_sum (map (fun it => reptype (field_type (fst it) m)) m).

Notation REPTYPE t :=
  match t return Type with
  | Tvoid
  | Tfunction _ _ _ => unit
  | Tint _ _ _
  | Tlong _ _
  | Tfloat _ _
  | Tpointer _ _ => val
  | Tarray t0 n _ => @zlist (reptype t0) (default_val t0) (list_zlist (reptype t0) (default_val t0)) 0 n
  | Tstruct id _ => reptype_structlist (co_members (get_co id))
  | Tunion id _ => reptype_unionlist (co_members (get_co id))
  end.

Lemma reptype_ind: forall t,
  reptype t = REPTYPE t.
Proof.
  intros.
  unfold reptype.
  rewrite reptype_gen_ind.
  destruct t as [| | | | | | | id ? | id ?]; auto.
  + unfold default_val.
    destruct (reptype_gen t).
    reflexivity.
  + unfold compact_prod_sigT_type.
    pose proof get_co_members_no_replicate id.
    forget (co_members (get_co id)) as m.
    rewrite map_map.
    rewrite map_map.
    unfold reptype_structlist.
    f_equal.
  + unfold compact_sum_sigT_type.
    pose proof get_co_members_no_replicate id.
    forget (co_members (get_co id)) as m.
    rewrite map_map.
    rewrite map_map.
    unfold reptype_unionlist.
    f_equal.
Defined.

(*
Definition reptype_ind : forall t, reptype t = REPTYPE t :=
fun t : type =>
(fun
   H : @eq Type
         match
           match t return (@sigT Type (fun x : Type => x)) with
           | Tvoid =>
               match
                 type_is_by_value t return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tint _ _ _ =>
               match
                 type_is_by_value t return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tlong _ _ =>
               match
                 type_is_by_value t return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tfloat _ _ =>
               match
                 type_is_by_value t return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tpointer _ _ =>
               match
                 type_is_by_value t return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tarray t0 _ _ =>
               match
                 reptype_gen t0 return (@sigT Type (fun x0 : Type => x0))
               with
               | existT T _ =>
                   @existT Type (fun x : Type => x) (list T) (@nil T)
               end
           | Tfunction _ _ _ =>
               match
                 type_is_by_value t return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tstruct id _ =>
               @existT Type (fun x : Type => x)
                 (@compact_prod_sigT_type Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
                 (@compact_prod_sigT_value Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
           | Tunion id _ =>
               @existT Type (fun x : Type => x)
                 (@compact_sum_sigT_type Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
                 (@compact_sum_sigT_value Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
           end return Type
         with
         | existT t0 _ => t0
         end
         match t return Type with
         | Tvoid => unit
         | Tint _ _ _ => val
         | Tlong _ _ => val
         | Tfloat _ _ => val
         | Tpointer _ _ => val
         | Tarray t0 n _ =>
             @zlist
               match reptype_gen t0 return Type with
               | existT t1 _ => t1
               end (default_val t0)
               (list_zlist
                  match reptype_gen t0 return Type with
                  | existT t1 _ => t1
                  end (default_val t0)) Z0 n
         | Tfunction _ _ _ => unit
         | Tstruct id _ => reptype_structlist (co_members (@get_co cs id))
         | Tunion id _ => reptype_unionlist (co_members (@get_co cs id))
         end =>
 (fun
    lemma : @eq (@sigT Type (fun x : Type => x)) (reptype_gen t)
              match t return (@sigT Type (fun x : Type => x)) with
              | Tvoid =>
                  match
                    type_is_by_value t
                    return (@sigT Type (fun x : Type => x))
                  with
                  | true => @existT Type (fun x : Type => x) val Vundef
                  | false => @existT Type (fun x : Type => x) unit tt
                  end
              | Tint _ _ _ =>
                  match
                    type_is_by_value t
                    return (@sigT Type (fun x : Type => x))
                  with
                  | true => @existT Type (fun x : Type => x) val Vundef
                  | false => @existT Type (fun x : Type => x) unit tt
                  end
              | Tlong _ _ =>
                  match
                    type_is_by_value t
                    return (@sigT Type (fun x : Type => x))
                  with
                  | true => @existT Type (fun x : Type => x) val Vundef
                  | false => @existT Type (fun x : Type => x) unit tt
                  end
              | Tfloat _ _ =>
                  match
                    type_is_by_value t
                    return (@sigT Type (fun x : Type => x))
                  with
                  | true => @existT Type (fun x : Type => x) val Vundef
                  | false => @existT Type (fun x : Type => x) unit tt
                  end
              | Tpointer _ _ =>
                  match
                    type_is_by_value t
                    return (@sigT Type (fun x : Type => x))
                  with
                  | true => @existT Type (fun x : Type => x) val Vundef
                  | false => @existT Type (fun x : Type => x) unit tt
                  end
              | Tarray t0 _ _ =>
                  match
                    reptype_gen t0 return (@sigT Type (fun x0 : Type => x0))
                  with
                  | existT T _ =>
                      @existT Type (fun x : Type => x) (list T) (@nil T)
                  end
              | Tfunction _ _ _ =>
                  match
                    type_is_by_value t
                    return (@sigT Type (fun x : Type => x))
                  with
                  | true => @existT Type (fun x : Type => x) val Vundef
                  | false => @existT Type (fun x : Type => x) unit tt
                  end
              | Tstruct id _ =>
                  @existT Type (fun x : Type => x)
                    (@compact_prod_sigT_type Type (fun x : Type => x)
                       (@map type (@sigT Type (fun x : Type => x))
                          reptype_gen
                          (@map (prod ident type) type
                             (fun it : prod ident type =>
                              field_type (@fst ident type it)
                                (co_members (@get_co cs id)))
                             (co_members (@get_co cs id)))))
                    (@compact_prod_sigT_value Type 
                       (fun x : Type => x)
                       (@map type (@sigT Type (fun x : Type => x))
                          reptype_gen
                          (@map (prod ident type) type
                             (fun it : prod ident type =>
                              field_type (@fst ident type it)
                                (co_members (@get_co cs id)))
                             (co_members (@get_co cs id)))))
              | Tunion id _ =>
                  @existT Type (fun x : Type => x)
                    (@compact_sum_sigT_type Type (fun x : Type => x)
                       (@map type (@sigT Type (fun x : Type => x))
                          reptype_gen
                          (@map (prod ident type) type
                             (fun it : prod ident type =>
                              field_type (@fst ident type it)
                                (co_members (@get_co cs id)))
                             (co_members (@get_co cs id)))))
                    (@compact_sum_sigT_value Type (fun x : Type => x)
                       (@map type (@sigT Type (fun x : Type => x))
                          reptype_gen
                          (@map (prod ident type) type
                             (fun it : prod ident type =>
                              field_type (@fst ident type it)
                                (co_members (@get_co cs id)))
                             (co_members (@get_co cs id)))))
              end =>
  @floyd.Morphisms.trans_co_eq_inv_impl_morphism 
    Type (@eq Type) (@eq_Transitive Type)
    match reptype_gen t return Type with
    | existT t0 _ => t0
    end
    match
      match t return (@sigT Type (fun x : Type => x)) with
      | Tvoid =>
          match
            type_is_by_value t return (@sigT Type (fun x : Type => x))
          with
          | true => @existT Type (fun x : Type => x) val Vundef
          | false => @existT Type (fun x : Type => x) unit tt
          end
      | Tint _ _ _ =>
          match
            type_is_by_value t return (@sigT Type (fun x : Type => x))
          with
          | true => @existT Type (fun x : Type => x) val Vundef
          | false => @existT Type (fun x : Type => x) unit tt
          end
      | Tlong _ _ =>
          match
            type_is_by_value t return (@sigT Type (fun x : Type => x))
          with
          | true => @existT Type (fun x : Type => x) val Vundef
          | false => @existT Type (fun x : Type => x) unit tt
          end
      | Tfloat _ _ =>
          match
            type_is_by_value t return (@sigT Type (fun x : Type => x))
          with
          | true => @existT Type (fun x : Type => x) val Vundef
          | false => @existT Type (fun x : Type => x) unit tt
          end
      | Tpointer _ _ =>
          match
            type_is_by_value t return (@sigT Type (fun x : Type => x))
          with
          | true => @existT Type (fun x : Type => x) val Vundef
          | false => @existT Type (fun x : Type => x) unit tt
          end
      | Tarray t0 _ _ =>
          match reptype_gen t0 return (@sigT Type (fun x0 : Type => x0)) with
          | existT T _ => @existT Type (fun x : Type => x) (list T) (@nil T)
          end
      | Tfunction _ _ _ =>
          match
            type_is_by_value t return (@sigT Type (fun x : Type => x))
          with
          | true => @existT Type (fun x : Type => x) val Vundef
          | false => @existT Type (fun x : Type => x) unit tt
          end
      | Tstruct id _ =>
          @existT Type (fun x : Type => x)
            (@compact_prod_sigT_type Type (fun x : Type => x)
               (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                  (@map (prod ident type) type
                     (fun it : prod ident type =>
                      field_type (@fst ident type it)
                        (co_members (@get_co cs id)))
                     (co_members (@get_co cs id)))))
            (@compact_prod_sigT_value Type (fun x : Type => x)
               (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                  (@map (prod ident type) type
                     (fun it : prod ident type =>
                      field_type (@fst ident type it)
                        (co_members (@get_co cs id)))
                     (co_members (@get_co cs id)))))
      | Tunion id _ =>
          @existT Type (fun x : Type => x)
            (@compact_sum_sigT_type Type (fun x : Type => x)
               (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                  (@map (prod ident type) type
                     (fun it : prod ident type =>
                      field_type (@fst ident type it)
                        (co_members (@get_co cs id)))
                     (co_members (@get_co cs id)))))
            (@compact_sum_sigT_value Type (fun x : Type => x)
               (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                  (@map (prod ident type) type
                     (fun it : prod ident type =>
                      field_type (@fst ident type it)
                        (co_members (@get_co cs id)))
                     (co_members (@get_co cs id)))))
      end return Type
    with
    | existT t0 _ => t0
    end
    (@f_equal (@sigT Type (fun x : Type => x)) Type
       (fun H0 : @sigT Type (fun x : Type => x) =>
        match H0 return Type with
        | existT t0 _ => t0
        end) (reptype_gen t)
       match t return (@sigT Type (fun x : Type => x)) with
       | Tvoid =>
           match
             type_is_by_value t return (@sigT Type (fun x : Type => x))
           with
           | true => @existT Type (fun x : Type => x) val Vundef
           | false => @existT Type (fun x : Type => x) unit tt
           end
       | Tint _ _ _ =>
           match
             type_is_by_value t return (@sigT Type (fun x : Type => x))
           with
           | true => @existT Type (fun x : Type => x) val Vundef
           | false => @existT Type (fun x : Type => x) unit tt
           end
       | Tlong _ _ =>
           match
             type_is_by_value t return (@sigT Type (fun x : Type => x))
           with
           | true => @existT Type (fun x : Type => x) val Vundef
           | false => @existT Type (fun x : Type => x) unit tt
           end
       | Tfloat _ _ =>
           match
             type_is_by_value t return (@sigT Type (fun x : Type => x))
           with
           | true => @existT Type (fun x : Type => x) val Vundef
           | false => @existT Type (fun x : Type => x) unit tt
           end
       | Tpointer _ _ =>
           match
             type_is_by_value t return (@sigT Type (fun x : Type => x))
           with
           | true => @existT Type (fun x : Type => x) val Vundef
           | false => @existT Type (fun x : Type => x) unit tt
           end
       | Tarray t0 _ _ =>
           match
             reptype_gen t0 return (@sigT Type (fun x0 : Type => x0))
           with
           | existT T _ => @existT Type (fun x : Type => x) (list T) (@nil T)
           end
       | Tfunction _ _ _ =>
           match
             type_is_by_value t return (@sigT Type (fun x : Type => x))
           with
           | true => @existT Type (fun x : Type => x) val Vundef
           | false => @existT Type (fun x : Type => x) unit tt
           end
       | Tstruct id _ =>
           @existT Type (fun x : Type => x)
             (@compact_prod_sigT_type Type (fun x : Type => x)
                (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                   (@map (prod ident type) type
                      (fun it : prod ident type =>
                       field_type (@fst ident type it)
                         (co_members (@get_co cs id)))
                      (co_members (@get_co cs id)))))
             (@compact_prod_sigT_value Type (fun x : Type => x)
                (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                   (@map (prod ident type) type
                      (fun it : prod ident type =>
                       field_type (@fst ident type it)
                         (co_members (@get_co cs id)))
                      (co_members (@get_co cs id)))))
       | Tunion id _ =>
           @existT Type (fun x : Type => x)
             (@compact_sum_sigT_type Type (fun x : Type => x)
                (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                   (@map (prod ident type) type
                      (fun it : prod ident type =>
                       field_type (@fst ident type it)
                         (co_members (@get_co cs id)))
                      (co_members (@get_co cs id)))))
             (@compact_sum_sigT_value Type (fun x : Type => x)
                (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                   (@map (prod ident type) type
                      (fun it : prod ident type =>
                       field_type (@fst ident type it)
                         (co_members (@get_co cs id)))
                      (co_members (@get_co cs id)))))
       end lemma)
    match t return Type with
    | Tvoid => unit
    | Tint _ _ _ => val
    | Tlong _ _ => val
    | Tfloat _ _ => val
    | Tpointer _ _ => val
    | Tarray t0 n _ =>
        @zlist match reptype_gen t0 return Type with
               | existT t1 _ => t1
               end (default_val t0)
          (list_zlist
             match reptype_gen t0 return Type with
             | existT t1 _ => t1
             end (default_val t0)) Z0 n
    | Tfunction _ _ _ => unit
    | Tstruct id _ => reptype_structlist (co_members (@get_co cs id))
    | Tunion id _ => reptype_unionlist (co_members (@get_co cs id))
    end
    match t return Type with
    | Tvoid => unit
    | Tint _ _ _ => val
    | Tlong _ _ => val
    | Tfloat _ _ => val
    | Tpointer _ _ => val
    | Tarray t0 n _ =>
        @zlist match reptype_gen t0 return Type with
               | existT t1 _ => t1
               end (default_val t0)
          (list_zlist
             match reptype_gen t0 return Type with
             | existT t1 _ => t1
             end (default_val t0)) Z0 n
    | Tfunction _ _ _ => unit
    | Tstruct id _ => reptype_structlist (co_members (@get_co cs id))
    | Tunion id _ => reptype_unionlist (co_members (@get_co cs id))
    end
    (floyd.Morphisms.eq_proper_proxy Type
       match t return Type with
       | Tvoid => unit
       | Tint _ _ _ => val
       | Tlong _ _ => val
       | Tfloat _ _ => val
       | Tpointer _ _ => val
       | Tarray t0 n _ =>
           @zlist
             match reptype_gen t0 return Type with
             | existT t1 _ => t1
             end (default_val t0)
             (list_zlist
                match reptype_gen t0 return Type with
                | existT t1 _ => t1
                end (default_val t0)) Z0 n
       | Tfunction _ _ _ => unit
       | Tstruct id _ => reptype_structlist (co_members (@get_co cs id))
       | Tunion id _ => reptype_unionlist (co_members (@get_co cs id))
       end)) (reptype_gen_ind t) H)
  match
    t as t0
    return
      (@eq Type
         match
           match t0 return (@sigT Type (fun x : Type => x)) with
           | Tvoid =>
               match
                 type_is_by_value t0 return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tint _ _ _ =>
               match
                 type_is_by_value t0 return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tlong _ _ =>
               match
                 type_is_by_value t0 return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tfloat _ _ =>
               match
                 type_is_by_value t0 return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tpointer _ _ =>
               match
                 type_is_by_value t0 return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tarray t1 _ _ =>
               match
                 reptype_gen t1 return (@sigT Type (fun x0 : Type => x0))
               with
               | existT T _ =>
                   @existT Type (fun x : Type => x) (list T) (@nil T)
               end
           | Tfunction _ _ _ =>
               match
                 type_is_by_value t0 return (@sigT Type (fun x : Type => x))
               with
               | true => @existT Type (fun x : Type => x) val Vundef
               | false => @existT Type (fun x : Type => x) unit tt
               end
           | Tstruct id _ =>
               @existT Type (fun x : Type => x)
                 (@compact_prod_sigT_type Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
                 (@compact_prod_sigT_value Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
           | Tunion id _ =>
               @existT Type (fun x : Type => x)
                 (@compact_sum_sigT_type Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
                 (@compact_sum_sigT_value Type (fun x : Type => x)
                    (@map type (@sigT Type (fun x : Type => x)) reptype_gen
                       (@map (prod ident type) type
                          (fun it : prod ident type =>
                           field_type (@fst ident type it)
                             (co_members (@get_co cs id)))
                          (co_members (@get_co cs id)))))
           end return Type
         with
         | existT t1 _ => t1
         end
         match t0 return Type with
         | Tvoid => unit
         | Tint _ _ _ => val
         | Tlong _ _ => val
         | Tfloat _ _ => val
         | Tpointer _ _ => val
         | Tarray t1 n _ =>
             @zlist
               match reptype_gen t1 return Type with
               | existT t2 _ => t2
               end (default_val t1)
               (list_zlist
                  match reptype_gen t1 return Type with
                  | existT t2 _ => t2
                  end (default_val t1)) Z0 n
         | Tfunction _ _ _ => unit
         | Tstruct id _ => reptype_structlist (co_members (@get_co cs id))
         | Tunion id _ => reptype_unionlist (co_members (@get_co cs id))
         end)
  with
  | Tvoid => @eq_refl Type unit
  | Tint _ _ _ => @eq_refl Type val
  | Tlong _ _ => @eq_refl Type val
  | Tfloat _ _ => @eq_refl Type val
  | Tpointer _ _ => @eq_refl Type val
  | Tarray t0 z _ =>
      let s := reptype_gen t0 in
      match
        s as s0
        return
          (@eq Type
             match
               match s0 return (@sigT Type (fun x0 : Type => x0)) with
               | existT T _ =>
                   @existT Type (fun x : Type => x) (list T) (@nil T)
               end return Type
             with
             | existT t1 _ => t1
             end
             (@zlist match s0 return Type with
                     | existT t1 _ => t1
                     end
                match
                  s0 as tv
                  return match tv return Type with
                         | existT t1 _ => t1
                         end
                with
                | existT t1 v => v
                end
                (list_zlist match s0 return Type with
                            | existT t1 _ => t1
                            end
                   match
                     s0 as tv
                     return match tv return Type with
                            | existT t1 _ => t1
                            end
                   with
                   | existT t1 v => v
                   end) Z0 z))
      with
      | existT x p => @eq_refl Type (@zlist x p (list_zlist x p) Z0 z)
      end
  | Tfunction _ _ _ => @eq_refl Type unit
  | Tstruct id _ =>
      (fun
         _ : @eq bool (members_no_replicate (co_members (@get_co cs id)))
               true =>
       let m := co_members (@get_co cs id) in
       @eq_ind_r (list Type)
         (@map type Type
            (fun x : type =>
             match reptype_gen x return Type with
             | existT t0 _ => t0
             end)
            (@map (prod ident type) type
               (fun it : prod ident type => field_type (@fst ident type it) m)
               m))
         (fun l : list Type =>
          @eq Type (compact_prod l) (reptype_structlist m))
         (@eq_ind_r (list Type)
            (@map (prod ident type) Type
               (fun x : prod ident type =>
                match
                  reptype_gen (field_type (@fst ident type x) m) return Type
                with
                | existT t0 _ => t0
                end) m)
            (fun l : list Type =>
             @eq Type (compact_prod l) (reptype_structlist m))
            ((fun
                H0 : @eq (list Type)
                       (@map (prod ident type) Type
                          (fun x : prod ident type =>
                           match
                             reptype_gen (field_type (@fst ident type x) m)
                             return Type
                           with
                           | existT t0 _ => t0
                           end) m)
                       (@map (prod ident type) Type
                          (fun it : prod ident type =>
                           reptype (field_type (@fst ident type it) m)) m) =>
              (fun
                 H1 : @eq (list Type)
                        (@map (prod ident type) Type
                           (fun x : prod ident type =>
                            match
                              reptype_gen (field_type (@fst ident type x) m)
                              return Type
                            with
                            | existT t0 _ => t0
                            end) m)
                        (@map (prod ident type) Type
                           (fun it : prod ident type =>
                            reptype (field_type (@fst ident type it) m)) m) =>
               @eq_trans Type
                 (compact_prod
                    (@map (prod ident type) Type
                       (fun x : prod ident type =>
                        match
                          reptype_gen (field_type (@fst ident type x) m)
                          return Type
                        with
                        | existT t0 _ => t0
                        end) m))
                 (compact_prod
                    (@map (prod ident type) Type
                       (fun x : prod ident type =>
                        match
                          reptype_gen (field_type (@fst ident type x) m)
                          return Type
                        with
                        | existT t0 _ => t0
                        end) m))
                 (compact_prod
                    (@map (prod ident type) Type
                       (fun it : prod ident type =>
                        reptype (field_type (@fst ident type it) m)) m))
                 (@f_equal (list Type -> Type) Type
                    (fun f : list Type -> Type =>
                     f
                       (@map (prod ident type) Type
                          (fun x : prod ident type =>
                           match
                             reptype_gen (field_type (@fst ident type x) m)
                             return Type
                           with
                           | existT t0 _ => t0
                           end) m)) compact_prod compact_prod
                    (@eq_refl (list Type -> Type) compact_prod))
                 (@f_equal (list Type) Type compact_prod
                    (@map (prod ident type) Type
                       (fun x : prod ident type =>
                        match
                          reptype_gen (field_type (@fst ident type x) m)
                          return Type
                        with
                        | existT t0 _ => t0
                        end) m)
                    (@map (prod ident type) Type
                       (fun it : prod ident type =>
                        reptype (field_type (@fst ident type it) m)) m) H1))
                H0)
               (@eq_refl (list Type)
                  (@map (prod ident type) Type
                     (fun it : prod ident type =>
                      reptype (field_type (@fst ident type it) m)) m)))
            (@map type Type
               (fun x : type =>
                match reptype_gen x return Type with
                | existT t0 _ => t0
                end)
               (@map (prod ident type) type
                  (fun it : prod ident type =>
                   field_type (@fst ident type it) m) m))
            (@map_map (prod ident type) type Type
               (fun it : prod ident type => field_type (@fst ident type it) m)
               (fun x : type =>
                match reptype_gen x return Type with
                | existT t0 _ => t0
                end) m))
         (@map (@sigT Type (fun x : Type => x)) Type
            (fun tv : @sigT Type (fun x : Type => x) =>
             match tv return Type with
             | existT t0 _ => t0
             end)
            (@map type (@sigT Type (fun x : Type => x)) reptype_gen
               (@map (prod ident type) type
                  (fun it : prod ident type =>
                   field_type (@fst ident type it) m) m)))
         (@map_map type (@sigT Type (fun x : Type => x)) 
            Type reptype_gen
            (fun tv : @sigT Type (fun x : Type => x) =>
             match tv return Type with
             | existT t0 _ => t0
             end)
            (@map (prod ident type) type
               (fun it : prod ident type => field_type (@fst ident type it) m)
               m))) (@get_co_members_no_replicate cs csl id)
  | Tunion id _ =>
      (fun
         _ : @eq bool (members_no_replicate (co_members (@get_co cs id)))
               true =>
       let m := co_members (@get_co cs id) in
       @eq_ind_r (list Type)
         (@map type Type
            (fun x : type =>
             match reptype_gen x return Type with
             | existT t0 _ => t0
             end)
            (@map (prod ident type) type
               (fun it : prod ident type => field_type (@fst ident type it) m)
               m))
         (fun l : list Type => @eq Type (compact_sum l) (reptype_unionlist m))
         (@eq_ind_r (list Type)
            (@map (prod ident type) Type
               (fun x : prod ident type =>
                match
                  reptype_gen (field_type (@fst ident type x) m) return Type
                with
                | existT t0 _ => t0
                end) m)
            (fun l : list Type =>
             @eq Type (compact_sum l) (reptype_unionlist m))
            ((fun
                H0 : @eq (list Type)
                       (@map (prod ident type) Type
                          (fun x : prod ident type =>
                           match
                             reptype_gen (field_type (@fst ident type x) m)
                             return Type
                           with
                           | existT t0 _ => t0
                           end) m)
                       (@map (prod ident type) Type
                          (fun it : prod ident type =>
                           reptype (field_type (@fst ident type it) m)) m) =>
              (fun
                 H1 : @eq (list Type)
                        (@map (prod ident type) Type
                           (fun x : prod ident type =>
                            match
                              reptype_gen (field_type (@fst ident type x) m)
                              return Type
                            with
                            | existT t0 _ => t0
                            end) m)
                        (@map (prod ident type) Type
                           (fun it : prod ident type =>
                            reptype (field_type (@fst ident type it) m)) m) =>
               @eq_trans Type
                 (compact_sum
                    (@map (prod ident type) Type
                       (fun x : prod ident type =>
                        match
                          reptype_gen (field_type (@fst ident type x) m)
                          return Type
                        with
                        | existT t0 _ => t0
                        end) m))
                 (compact_sum
                    (@map (prod ident type) Type
                       (fun x : prod ident type =>
                        match
                          reptype_gen (field_type (@fst ident type x) m)
                          return Type
                        with
                        | existT t0 _ => t0
                        end) m))
                 (compact_sum
                    (@map (prod ident type) Type
                       (fun it : prod ident type =>
                        reptype (field_type (@fst ident type it) m)) m))
                 (@f_equal (list Type -> Type) Type
                    (fun f : list Type -> Type =>
                     f
                       (@map (prod ident type) Type
                          (fun x : prod ident type =>
                           match
                             reptype_gen (field_type (@fst ident type x) m)
                             return Type
                           with
                           | existT t0 _ => t0
                           end) m)) compact_sum compact_sum
                    (@eq_refl (list Type -> Type) compact_sum))
                 (@f_equal (list Type) Type compact_sum
                    (@map (prod ident type) Type
                       (fun x : prod ident type =>
                        match
                          reptype_gen (field_type (@fst ident type x) m)
                          return Type
                        with
                        | existT t0 _ => t0
                        end) m)
                    (@map (prod ident type) Type
                       (fun it : prod ident type =>
                        reptype (field_type (@fst ident type it) m)) m) H1))
                H0)
               (@eq_refl (list Type)
                  (@map (prod ident type) Type
                     (fun it : prod ident type =>
                      reptype (field_type (@fst ident type it) m)) m)))
            (@map type Type
               (fun x : type =>
                match reptype_gen x return Type with
                | existT t0 _ => t0
                end)
               (@map (prod ident type) type
                  (fun it : prod ident type =>
                   field_type (@fst ident type it) m) m))
            (@map_map (prod ident type) type Type
               (fun it : prod ident type => field_type (@fst ident type it) m)
               (fun x : type =>
                match reptype_gen x return Type with
                | existT t0 _ => t0
                end) m))
         (@map (@sigT Type (fun x : Type => x)) Type
            (fun tv : @sigT Type (fun x : Type => x) =>
             match tv return Type with
             | existT t0 _ => t0
             end)
            (@map type (@sigT Type (fun x : Type => x)) reptype_gen
               (@map (prod ident type) type
                  (fun it : prod ident type =>
                   field_type (@fst ident type it) m) m)))
         (@map_map type (@sigT Type (fun x : Type => x)) 
            Type reptype_gen
            (fun tv : @sigT Type (fun x : Type => x) =>
             match tv return Type with
             | existT t0 _ => t0
             end)
            (@map (prod ident type) type
               (fun it : prod ident type => field_type (@fst ident type it) m)
               m))) (@get_co_members_no_replicate cs csl id)
  end.
*)
Definition unfold_reptype {t} (v: reptype t): REPTYPE t :=
  @eq_rect Type (reptype t) (fun x: Type => x) v (REPTYPE t) (reptype_ind t).

Definition fold_reptype {t} (v: REPTYPE t): reptype t :=
  @eq_rect_r Type (REPTYPE t) (fun x: Type => x) v (reptype t) (reptype_ind t).

Lemma fold_unfold_reptype: forall t (v: reptype t),
  fold_reptype (unfold_reptype v) = v.
Proof.
  intros.
  unfold fold_reptype, unfold_reptype.
  apply JMeq_eq.
  match goal with
  | |- JMeq (@eq_rect_r ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_r_JMeq A x y F v H)
  end.
  match goal with
  | |- JMeq (@eq_rect ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_JMeq A x y F v H)
  end.
  reflexivity.
Defined.

Lemma unfold_fold_reptype: forall t (v: REPTYPE t),
  unfold_reptype (fold_reptype v) = v.
Proof.
  intros.
  unfold fold_reptype, unfold_reptype.
  apply JMeq_eq.
  match goal with
  | |- JMeq (@eq_rect ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_JMeq A x y F v H)
  end.
  match goal with
  | |- JMeq (@eq_rect_r ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_r_JMeq A x y F v H)
  end.
  reflexivity.
Defined.

Lemma unfold_reptype_JMeq: forall t (v: reptype t),
  JMeq (unfold_reptype v) v.
Proof.
  intros.
  unfold unfold_reptype.
  match goal with
  | |- JMeq (@eq_rect ?A ?x ?F ?v ?y ?H) _ =>
    apply (eq_rect_JMeq A x y F v H)
  end.
Qed.

Lemma fold_reptype_JMeq: forall t v,
  JMeq (fold_reptype v : reptype t) v.
Proof.
  intros.
  unfold fold_reptype.
  match goal with
  | |- JMeq (@eq_rect_r ?A ?x ?F ?v ?y ?H) _ =>
    apply (eq_rect_r_JMeq A x y F v H)
  end.
Qed.

Definition union_default_filter m :=
  match m with
  | nil => fun _ => false
  | hd :: _ => fun m => if member_dec hd m then true else false
  end.

Definition is_default_filter {A} f (l: list A) :=
  match l with
  | nil => True
  | hd :: _ => f hd = true
  end.

Lemma union_default_filter_is_default_filter: forall m, is_default_filter (union_default_filter m) m.
Proof.
  intros.
  destruct m; simpl; auto.
  destruct (member_dec p p); auto.
Qed.
(*
Lemma union_default_filter_legal: forall m, m <> nil ->
  legal_compact_sum_filter (union_default_filter m) m = true.
Proof.
  intros.
  destruct m; auto.
  simpl.
  destruct (member_dec p p); [| congruence].
  auto.
Qed.
*)
Definition struct_default_val (m : members) := compact_prod_gen (fun it => default_val (field_type (fst it) m)) m.
Definition union_default_val (m : members) := compact_sum_gen (union_default_filter m) (fun it => default_val (field_type (fst it) m)) m.

Lemma compact_prod_sigT_compact_prod_gen:
  forall {A B} {P: A -> Type} (genT: B -> A) (genV: forall b: B, P (genT b)) (gen: B -> sigT P) (l: list B),
    (forall b, gen b = existT P (genT b) (genV b)) ->
    JMeq (compact_prod_sigT_value (map gen l)) (compact_prod_gen genV l).
Proof.
  intros.
  assert (gen = fun b => existT P (genT b) (genV b)) by (extensionality; apply H).
  rewrite H0; clear H H0 gen.
  destruct l; [reflexivity |].
  revert b; induction l; intros.
  + reflexivity.
  + simpl map.
    change (compact_prod_gen genV (b :: a :: l)) with (genV b, compact_prod_gen genV (a :: l)).
    change (compact_prod_sigT_value
        (existT P (genT b) (genV b)
         :: existT P (genT a) (genV a)
            :: map (fun b0 : B => existT P (genT b0) (genV b0)) l)) with
      (genV b, compact_prod_sigT_value (existT P (genT a) (genV a) :: map (fun b0 : B => existT P (genT b0) (genV b0)) l)).
    apply JMeq_pair; [auto |].
    exact (IHl a).
Qed.

Lemma compact_sum_sigT_compact_sum_gen:
  forall {A B} {P: A -> Type} (genT: B -> A) (genV: forall b: B, P (genT b)) (filter: B -> bool) (gen: B -> sigT P) (l: list B),
    (forall b, gen b = existT P (genT b) (genV b)) ->
    is_default_filter filter l ->
    JMeq (compact_sum_sigT_value (map gen l)) (compact_sum_gen filter genV l).
Proof.
  intros.
  assert (gen = fun b => existT P (genT b) (genV b)) by (extensionality; apply H).
  rewrite H1; clear H H1 gen.
  destruct l; [reflexivity |].
  destruct l.
  + reflexivity.
  + change (compact_sum_sigT_value
        (map (fun b1 : B => existT P (genT b1) (genV b1)) (b :: b0 :: l))) with
  (@inl (P (genT b)) (compact_sum (map (fun tv => match tv with existT t _ => P t end) (map (fun b1 : B => @existT A P (genT b1) (genV b1)) (b0 :: l)))) (genV b)).
    change (compact_sum (map (fun tv => match tv with existT t _ => P t end) (map (fun b1 : B => @existT A P (genT b1) (genV b1)) (b :: b0 :: l)))) with
      (P (genT b) + compact_sum (map (fun tv => match tv with existT t _ => P t end) (map (fun b1 : B => @existT A P (genT b1) (genV b1)) (b0 :: l))))%type.
    replace (compact_sum_gen filter genV (b :: b0 :: l)) with
      (@inl (P (genT b)) (compact_sum (map (fun b1 : B => P (genT b1)) (b0 :: l))) (genV b)).
    Focus 2. {
      simpl in H0 |- *.
      rewrite H0.
      auto.
    } Unfocus.
    match goal with
    | |- @JMeq _ (@inl _ ?A _) _ (@inl _ ?B _) =>
         replace A with B; [auto |]
    end.
    rewrite map_map; reflexivity.
Qed.

Lemma default_val_ind: forall t,
  default_val t =
  fold_reptype
  match t as t' return REPTYPE t'
  with
  | Tvoid
  | Tfunction _ _ _ => tt
  | Tint _ _ _
  | Tlong _ _
  | Tfloat _ _
  | Tpointer _ _ => Vundef
  | Tarray t0 n _ => zl_default 0 n
  | Tstruct id _ => struct_default_val (co_members (get_co id))
  | Tunion id _ => union_default_val (co_members (get_co id))
  end.
Proof.
  intros.
  unfold fold_reptype.
  apply JMeq_eq.
  match goal with
  | |- JMeq _ (@eq_rect_r ?A ?x ?F ?v ?y ?H) =>
    rewrite (eq_rect_r_JMeq A x y F v H)
  end.
  unfold default_val.
  unfold reptype at 1.
  rewrite reptype_gen_ind.
  destruct t; auto.
  + unfold reptype.
    destruct (reptype_gen t).
    reflexivity.
  + unfold struct_default_val.
    rewrite map_map.
    apply (compact_prod_sigT_compact_prod_gen
      (fun it => reptype (field_type (fst it) (co_members (get_co i))))
      (fun it => default_val (field_type (fst it) (co_members (get_co i))))
      (fun it => reptype_gen (field_type (fst it) (co_members (get_co i))))); intros.
    unfold reptype, default_val.
    destruct (reptype_gen (field_type (fst b) (co_members (get_co i)))); reflexivity.
  + unfold union_default_val.
    rewrite map_map.
    apply (compact_sum_sigT_compact_sum_gen
      (fun it => reptype (field_type (fst it) (co_members (get_co i))))
      (fun it => default_val (field_type (fst it) (co_members (get_co i))))
      _
      (fun it => reptype_gen (field_type (fst it) (co_members (get_co i))))); intros.
    unfold reptype, default_val.
    destruct (reptype_gen (field_type (fst b) (co_members (get_co i)))); reflexivity.
    apply union_default_filter_is_default_filter.
Qed.

Definition reptype': type -> Type :=
  func_type (fun _ => Type)
  (fun t =>
     if (type_is_by_value t)
     then match t with
          | Tint _ _ _ => int
          | Tlong _ _ => Int64.int
          | Tfloat _ _ => float
          | _ => val
          end
     else unit)
  (fun t n a T => list T)
  (fun id a T => compact_prod (decay T))
  (fun id a T => compact_sum (decay T)).

Notation REPTYPE' t :=
  match t return Type with
  | Tvoid
  | Tfunction _ _ _ => unit
  | Tint _ _ a => int
  | Tlong _ a => Int64.int
  | Tfloat _ a => float
  | Tpointer _ a => val
  | Tarray t0 _ _ => list (reptype' t0)
  | Tstruct id _ => compact_prod (map (fun it => reptype' (field_type (fst it) (co_members (get_co id)))) (co_members (get_co id)))
  | Tunion id _ => compact_sum (map (fun it => reptype' (field_type (fst it) (co_members (get_co id)))) (co_members (get_co id)))
  end.

Lemma reptype'_ind: forall t, 
  reptype' t = REPTYPE' t.
Proof.
  intros.
  unfold reptype'.
  rewrite func_type_ind with (t0 := t) (A := (fun _ => Type)) at 1 by auto.
  destruct t; auto.
  + f_equal.
    rewrite decay_spec.
    reflexivity.
  + f_equal.
    rewrite decay_spec.
    reflexivity.
Qed.

Definition unfold_reptype' {t} (v: reptype' t): REPTYPE' t :=
  @eq_rect Type (reptype' t) (fun x: Type => x) v (REPTYPE' t) (reptype'_ind t).

Definition fold_reptype' {t} (v: REPTYPE' t): reptype' t :=
  @eq_rect_r Type (REPTYPE' t) (fun x: Type => x) v (reptype' t) (reptype'_ind t).

Lemma fold_unfold_reptype': forall t (v: reptype' t),
  fold_reptype' (unfold_reptype' v) = v.
Proof.
  intros.
  unfold fold_reptype', unfold_reptype'.
  apply JMeq_eq.
  match goal with
  | |- JMeq (@eq_rect_r ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_r_JMeq A x y F v H)
  end.
  match goal with
  | |- JMeq (@eq_rect ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_JMeq A x y F v H)
  end.
  reflexivity.
Defined.

Lemma unfold_fold_reptype': forall t (v: REPTYPE' t),
  unfold_reptype' (fold_reptype' v) = v.
Proof.
  intros.
  unfold fold_reptype', unfold_reptype'.
  apply JMeq_eq.
  match goal with
  | |- JMeq (@eq_rect ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_JMeq A x y F v H)
  end.
  match goal with
  | |- JMeq (@eq_rect_r ?A ?x ?F ?v ?y ?H) _ =>
    rewrite (eq_rect_r_JMeq A x y F v H)
  end.
  reflexivity.
Defined.

Definition repinj_bv (t: type): reptype' t -> reptype t :=
  fun v =>
  fold_reptype
  (match t as t' return (REPTYPE' t' -> REPTYPE t': Type)
   with
   | Tvoid
   | Tfunction _ _ _ => @id unit
   | Tint _ _ a => Vint
   | Tlong _ a => Vlong
   | Tfloat _ a => Vfloat
   | Tpointer _ a => id
   | Tarray t0 n a => fun _ => nil
   | Tstruct id a => fun _ => struct_default_val _
   | Tunion id a => fun _ => union_default_val _
   end (unfold_reptype' v)).

Definition repinj_aux_s (id: ident) (a: attr) (F: ListType (map (fun it => reptype' (field_type (fst it) (co_members (get_co id))) -> reptype (field_type (fst it) (co_members (get_co id)))) (co_members (get_co id)))): reptype' (Tstruct id a) -> reptype (Tstruct id a) :=
  fun v => @fold_reptype (Tstruct id a) (compact_prod_map _ F (unfold_reptype' v)).

Definition repinj_aux_u (id: ident) (a: attr) (F: ListType (map (fun it => reptype' (field_type (fst it) (co_members (get_co id))) -> reptype (field_type (fst it) (co_members (get_co id)))) (co_members (get_co id)))): reptype' (Tunion id a) -> reptype (Tunion id a) :=
  fun v => @fold_reptype (Tunion id a) (compact_sum_map _ F (unfold_reptype' v)).

Definition repinj: forall t: type, reptype' t -> reptype t :=
  func_type (fun t => reptype' t -> reptype t)
  repinj_bv
  (fun t n a f v => @fold_reptype (Tarray t n a) (map f (unfold_reptype' v)))
  repinj_aux_s
  repinj_aux_u.

Lemma repinj_ind: forall t v,
  repinj t v =
  fold_reptype
  (match t as t' return REPTYPE' t' -> REPTYPE t' with
   | Tvoid
   | Tfunction _ _ _ => @id unit
   | Tint _ _ a => Vint
   | Tlong _ a => Vlong
   | Tfloat _ a => Vfloat
   | Tpointer _ a => id
   | Tarray t0 _ _ => map (repinj t0)
   | Tstruct id a => compact_prod_map _ (ListTypeGen (fun it => reptype' (field_type (fst it) (co_members (get_co id))) -> reptype (field_type (fst it) (co_members (get_co id)))) (fun it => repinj (field_type (fst it) (co_members (get_co id)))) (co_members (get_co id)))
   | Tunion id a => compact_sum_map _ (ListTypeGen (fun it => reptype' (field_type (fst it) (co_members (get_co id))) -> reptype (field_type (fst it) (co_members (get_co id)))) (fun it => repinj (field_type (fst it) (co_members (get_co id)))) (co_members (get_co id)))
   end (unfold_reptype' v)).
Proof.
  intros.
  unfold repinj.
  rewrite func_type_ind.
  destruct t; auto.
Qed.

Lemma int_add_repr_0_l: forall i, Int.add (Int.repr 0) i = i.
Proof. intros. apply Int.add_zero_l. Qed.
Lemma int_add_repr_0_r: forall i, Int.add i (Int.repr 0) = i.
Proof. intros. apply Int.add_zero. Qed.
Hint Rewrite int_add_repr_0_l int_add_repr_0_r : norm.

Definition repinject (t: type) : reptype t -> val :=
  match t as t0 return reptype t0 -> val with
  | Tint _ _ _ => fun v => v
  | Tlong _ _ => fun v => v
  | Tfloat _ _ => fun v => v
  | Tpointer _ _ => fun v => v
  | _ => fun _ => Vundef
 end.

Definition valinject (t: type) : val -> reptype t :=
  match t as t0 return val -> reptype t0 with
  | Tint _ _ _ => fun v => v
  | Tlong _ _ => fun v => v
  | Tfloat _ _ => fun v => v
  | Tpointer _ _ => fun v => v
  | t => fun _ => default_val t
 end.

Lemma valinject_JMeq: forall t v, type_is_by_value t = true -> JMeq (valinject t v) v.
Proof.
  intros.
  destruct t; simpl in *; try congruence; try tauto.
Qed.

Lemma repinject_unfold_reptype: forall t v,
  match t as t' return REPTYPE t' -> Prop with
  | Tint _ _ _
  | Tfloat _ _
  | Tlong _ _
  | Tpointer _ _ => fun vv => repinject t v = vv
  | _ => fun _ => True
  end (unfold_reptype v).
Proof.
  intros; destruct t; auto;
  unfold repinject;
  unfold unfold_reptype;
  rewrite <- eq_rect_eq; auto.
Qed.

Lemma repinject_valinject:
  forall t v,
    type_is_by_value t = true -> repinject t (valinject t v) = v.
Proof.
  intros.
  destruct t; try inversion H; reflexivity.
Qed.

Lemma valinject_repinject: forall t v,
  type_is_by_value t = true ->
  (valinject t (repinject t v)) = v.
Proof.
  intros.
  destruct t; inversion H; reflexivity.
Qed.

Lemma repinject_default_val:
 forall t, repinject t (default_val t) = Vundef.
Proof.
destruct t; reflexivity.
Qed.

End CENV.

Global Notation REPTYPE t :=
  match t return Type with
  | Tvoid
  | Tfunction _ _ _ => unit
  | Tint _ _ _
  | Tlong _ _
  | Tfloat _ _
  | Tpointer _ _ => val
  | Tarray t0 n _ => @zlist (reptype t0) (default_val t0) (list_zlist (reptype t0) (default_val t0)) 0 n
  | Tstruct id _ => reptype_structlist (co_members (get_co id))
  | Tunion id _ => reptype_unionlist (co_members (get_co id))
  end.