(***********************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team    *)
(* <O___,, *        INRIA-Rocquencourt  &  LRI-CNRS-Orsay              *)
(*   \VV/  *************************************************************)
(*    //   *      This file is distributed under the terms of the      *)
(*         *       GNU Lesser General Public License Version 2.1       *)
(***********************************************************************)
 
(*i $Id$ i*)

Require Rbase.
Require Rbasic_fun.
Require DiscrR.
Require Rderiv.
Require Alembert.
Require Ranalysis1.
Require Classical_Prop.
Require Classical_Pred_Type.

Definition inclus [D1,D2:R->Prop] : Prop := (x:R)(D1 x)->(D2 x).
Definition Disque [x:R;delta:posreal] : R->Prop := [y:R]``(Rabsolu (y-x))<delta``.
Definition voisinage [V:R->Prop;x:R] : Prop := (EXT delta:posreal | (inclus (Disque x delta) V)).
(* Une partie est ouverte ssi c'est un voisinage de chacun de ses points *)
Definition ouvert [D:R->Prop] : Prop := (x:R) (D x)->(voisinage D x).
Definition complementaire [D:R->Prop] : R->Prop := [c:R]~(D c).
Definition ferme [D:R->Prop] : Prop := (ouvert (complementaire D)).
Definition intersection_domaine [D1,D2:R->Prop] : R->Prop := [c:R](D1 c)/\(D2 c).
Definition union_domaine [D1,D2:R->Prop] : R->Prop := [c:R](D1 c)\/(D2 c).
Definition interieur [D:R->Prop] : R->Prop := [x:R](voisinage D x).

(* D� est inclus dans D *)
Lemma interieur_P1 : (D:R->Prop) (inclus (interieur D) D).
Intros; Unfold inclus; Unfold interieur; Intros; Unfold voisinage in H; Elim H; Intros; Unfold inclus in H0; Apply H0; Unfold Disque; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Apply (cond_pos x0).
Qed.

Lemma interieur_P2 : (D:R->Prop) (ouvert D) -> (inclus D (interieur D)).
Intros; Unfold ouvert in H; Unfold inclus; Intros; Assert H1 := (H ? H0); Unfold interieur; Apply H1.
Qed.

Definition point_adherent [D:R->Prop;x:R] : Prop := (V:R->Prop) (voisinage V x) -> (EXT y:R | (intersection_domaine V D y)).
Definition adherence [D:R->Prop] : R->Prop := [x:R](point_adherent D x).

Lemma adherence_P1 : (D:R->Prop) (inclus D (adherence D)).
Intro; Unfold inclus; Intros; Unfold adherence; Unfold point_adherent; Intros; Exists x; Unfold intersection_domaine; Split.
Unfold voisinage in H0; Elim H0; Intros; Unfold inclus in H1; Apply H1; Unfold Disque; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Apply (cond_pos x0).
Apply H.
Qed.

Lemma inclus_trans : (D1,D2,D3:R->Prop) (inclus D1 D2) -> (inclus D2 D3) -> (inclus D1 D3).
Unfold inclus; Intros; Apply H0; Apply H; Apply H1.
Qed.

(* D� est ouvert *)
Lemma interieur_P3 : (D:R->Prop) (ouvert (interieur D)).
Intro; Unfold ouvert interieur; Unfold voisinage; Intros; Elim H; Intros.
Exists x0; Unfold inclus; Intros.
Pose del := ``x0-(Rabsolu (x-x1))``.
Cut ``0<del``.
Intro; Exists (mkposreal del H2); Intros.
Cut (inclus (Disque x1 (mkposreal del H2)) (Disque x x0)).
Intro; Assert H5 := (inclus_trans ? ? ? H4 H0).
Apply H5; Apply H3.
Unfold inclus; Unfold Disque; Intros.
Apply Rle_lt_trans with ``(Rabsolu (x3-x1))+(Rabsolu (x1-x))``.
Replace ``x3-x`` with ``(x3-x1)+(x1-x)``; [Apply Rabsolu_triang | Ring].
Replace (pos x0) with ``del+(Rabsolu (x1-x))``.
Do 2 Rewrite <- (Rplus_sym (Rabsolu ``x1-x``)); Apply Rlt_compatibility; Apply H4.
Unfold del; Rewrite <- (Rabsolu_Ropp ``x-x1``); Rewrite Ropp_distr2; Ring.
Unfold del; Apply Rlt_anti_compatibility with ``(Rabsolu (x-x1))``; Rewrite Rplus_Or; Replace ``(Rabsolu (x-x1))+(x0-(Rabsolu (x-x1)))`` with (pos x0); [Idtac | Ring].
Unfold Disque in H1; Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply H1.
Qed.

Lemma complementaire_P1 : (D:R->Prop) ~(EXT y:R | (intersection_domaine D (complementaire D) y)).
Intro; Red; Intro; Elim H; Intros; Unfold intersection_domaine complementaire in H0; Elim H0; Intros; Elim H2; Assumption.
Qed.

Lemma adherence_P2 : (D:R->Prop) (ferme D) -> (inclus (adherence D) D).
Unfold ferme; Unfold ouvert complementaire; Intros; Unfold inclus adherence; Intros; Assert H1 := (classic (D x)); Elim H1; Intro.
Assumption.
Assert H3 := (H ? H2); Assert H4 := (H0 ? H3); Elim H4; Intros; Unfold intersection_domaine in H5; Elim H5; Intros; Elim H6; Assumption.
Qed.

Lemma adherence_P3 : (D:R->Prop) (ferme (adherence D)).
Intro; Unfold ferme adherence; Unfold ouvert complementaire point_adherent; Intros; Pose P := [V:R->Prop](voisinage V x)->(EXT y:R | (intersection_domaine V D y)); Assert H0 := (not_all_ex_not ? P H); Elim H0; Intros V0 H1; Unfold P in H1; Assert H2 := (imply_to_and ? ? H1); Unfold voisinage; Elim H2; Intros; Unfold voisinage in H3; Elim H3; Intros; Exists x0; Unfold inclus; Intros; Red; Intro.
Assert H8 := (H7 V0); Cut (EXT delta:posreal | (x:R)(Disque x1 delta x)->(V0 x)).
Intro; Assert H10 := (H8 H9); Elim H4; Assumption.
Cut ``0<x0-(Rabsolu (x-x1))``.
Intro; Pose del := (mkposreal ? H9); Exists del; Intros; Unfold inclus in H5; Apply H5; Unfold Disque; Apply Rle_lt_trans with ``(Rabsolu (x2-x1))+(Rabsolu (x1-x))``.
Replace ``x2-x`` with ``(x2-x1)+(x1-x)``; [Apply Rabsolu_triang | Ring].
Replace (pos x0) with ``del+(Rabsolu (x1-x))``.
Do 2 Rewrite <- (Rplus_sym ``(Rabsolu (x1-x))``); Apply Rlt_compatibility; Apply H10.
Unfold del; Simpl; Rewrite <- (Rabsolu_Ropp ``x-x1``); Rewrite Ropp_distr2; Ring.
Apply Rlt_anti_compatibility with ``(Rabsolu (x-x1))``; Rewrite Rplus_Or; Replace ``(Rabsolu (x-x1))+(x0-(Rabsolu (x-x1)))`` with (pos x0); [Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply H6 | Ring].
Qed.

Definition eq_Dom [D1,D2:R->Prop] : Prop := (inclus D1 D2)/\(inclus D2 D1).

Infix 6 "=_D" eq_Dom.

Lemma ouvert_P1 : (D:R->Prop) (ouvert D) <-> D =_D (interieur D).
Intro; Split.
Intro; Unfold eq_Dom; Split.
Apply interieur_P2; Assumption.
Apply interieur_P1.
Intro; Unfold eq_Dom in H; Elim H; Clear H; Intros; Unfold ouvert; Intros; Unfold inclus interieur in H; Unfold inclus in H0; Apply (H ? H1).
Qed.

Lemma ferme_P1 : (D:R->Prop) (ferme D) <-> D =_D (adherence D).
Intro; Split.
Intro; Unfold eq_Dom; Split.
Apply adherence_P1.
Apply adherence_P2; Assumption.
Unfold eq_Dom; Unfold inclus; Intros; Assert H0 := (adherence_P3 D); Unfold ferme in H0; Unfold ferme; Unfold ouvert; Unfold ouvert in H0; Intros; Assert H2 : (complementaire (adherence D) x).
Unfold complementaire; Unfold complementaire in H1; Red; Intro; Elim H; Clear H; Intros _ H; Elim H1; Apply (H ? H2).
Assert H3 := (H0 ? H2); Unfold voisinage; Unfold voisinage in H3; Elim H3; Intros; Exists x0; Unfold inclus; Unfold inclus in H4; Intros; Assert H6 := (H4 ? H5); Unfold complementaire in H6; Unfold complementaire; Red; Intro; Elim H; Clear H; Intros H _; Elim H6; Apply (H ? H7).
Qed.

Lemma voisinage_P1 : (D1,D2:R->Prop;x:R) (inclus D1 D2) -> (voisinage D1 x) -> (voisinage D2 x).
Unfold inclus voisinage; Intros; Elim H0; Intros; Exists x0; Intros; Unfold inclus; Unfold inclus in H1; Intros; Apply (H ? (H1 ? H2)).
Qed.

Lemma ouvert_P2 : (D1,D2:R->Prop) (ouvert D1) -> (ouvert D2) -> (ouvert (union_domaine D1 D2)).
Unfold ouvert; Intros; Unfold union_domaine in H1; Elim H1; Intro.
Apply voisinage_P1 with D1.
Unfold inclus union_domaine; Tauto.
Apply H; Assumption.
Apply voisinage_P1 with D2.
Unfold inclus union_domaine; Tauto.
Apply H0; Assumption.
Qed.

Lemma ouvert_P3 : (D1,D2:R->Prop) (ouvert D1) -> (ouvert D2) -> (ouvert (intersection_domaine D1 D2)).
Unfold ouvert; Intros; Unfold intersection_domaine in H1; Elim H1; Intros.
Assert H4 := (H ? H2); Assert H5 := (H0 ? H3); Unfold intersection_domaine; Unfold voisinage in H4 H5; Elim H4; Clear H; Intros del1 H; Elim H5; Clear H0; Intros del2 H0; Cut ``0<(Rmin del1 del2)``.
Intro; Pose del := (mkposreal ? H6).
Exists del; Unfold inclus; Intros; Unfold inclus in H H0; Unfold Disque in H H0 H7.
Split.
Apply H; Apply Rlt_le_trans with (pos del).
Apply H7.
Unfold del; Simpl; Apply Rmin_l.
Apply H0; Apply Rlt_le_trans with (pos del).
Apply H7.
Unfold del; Simpl; Apply Rmin_r.
Unfold Rmin; Case (total_order_Rle del1 del2); Intro.
Apply (cond_pos del1).
Apply (cond_pos del2).
Qed.

Lemma ouvert_P4 : (ouvert [x:R]False).
Unfold ouvert; Intros; Elim H.
Qed.

Lemma ouvert_P5 : (ouvert [x:R]True).
Unfold ouvert; Intros; Unfold voisinage.
Exists (mkposreal R1 Rlt_R0_R1); Unfold inclus; Intros; Trivial.
Qed.

Lemma disque_P1 : (x:R;del:posreal) (ouvert (Disque x del)).
Intros; Assert H := (ouvert_P1 (Disque x del)).
Elim H; Intros; Apply H1.
Unfold eq_Dom; Split.
Unfold inclus interieur Disque; Intros; Cut ``0<del-(Rabsolu (x-x0))``.
Intro; Pose del2 := (mkposreal ? H3).
Exists del2; Unfold inclus; Intros.
Apply Rle_lt_trans with ``(Rabsolu (x1-x0))+(Rabsolu (x0 -x))``.
Replace ``x1-x`` with ``(x1-x0)+(x0-x)``; [Apply Rabsolu_triang | Ring].
Replace (pos del) with ``del2 + (Rabsolu (x0-x))``.
Do 2 Rewrite <- (Rplus_sym ``(Rabsolu (x0-x))``); Apply Rlt_compatibility.
Apply H4.
Unfold del2; Simpl; Rewrite <- (Rabsolu_Ropp ``x-x0``); Rewrite Ropp_distr2; Ring.
Apply Rlt_anti_compatibility with ``(Rabsolu (x-x0))``; Rewrite Rplus_Or; Replace ``(Rabsolu (x-x0))+(del-(Rabsolu (x-x0)))`` with (pos del); [Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply H2 | Ring].
Apply interieur_P1.
Qed.

Lemma continuity_P1 : (f:R->R;x:R) (continuity_pt f x) <-> (W:R->Prop)(voisinage W (f x)) -> (EXT V:R->Prop | (voisinage V x) /\ ((y:R)(V y)->(W (f y)))).
Intros; Split.
Intros; Unfold voisinage in H0.
Elim H0; Intros del1 H1.
Unfold continuity_pt in H; Unfold continue_in in H; Unfold limit1_in in H; Unfold limit_in in H; Simpl in H; Unfold R_dist in H.
Assert H2 := (H del1 (cond_pos del1)).
Elim H2; Intros del2 H3.
Elim H3; Intros.
Exists (Disque x (mkposreal del2 H4)).
Intros; Unfold inclus in H1; Split.
Unfold voisinage Disque.
Exists (mkposreal del2 H4).
Unfold inclus; Intros; Assumption.
Intros; Apply H1; Unfold Disque; Case (Req_EM y x); Intro.
Rewrite H7; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Apply (cond_pos del1).
Apply H5; Split.
Unfold D_x no_cond; Split.
Trivial.
Apply not_sym; Apply H7.
Unfold Disque in H6; Apply H6.
Intros; Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Intros.
Assert H1 := (H (Disque (f x) (mkposreal eps H0))).
Cut (voisinage (Disque (f x) (mkposreal eps H0)) (f x)).
Intro; Assert H3 := (H1 H2).
Elim H3; Intros D H4; Elim H4; Intros; Unfold voisinage in H5; Elim H5; Intros del1 H7.
Exists (pos del1); Split.
Apply (cond_pos del1).
Intros; Elim H8; Intros; Simpl in H10; Unfold R_dist in H10; Simpl; Unfold R_dist; Apply (H6 ? (H7 ? H10)).
Unfold voisinage Disque; Exists (mkposreal eps H0); Unfold inclus; Intros; Assumption.
Qed.

Definition image_rec [f:R->R;D:R->Prop] : R->Prop := [x:R](D (f x)).

(* L'image r�ciproque d'un ouvert par une fonction continue est un ouvert *)
Lemma continuity_P2 : (f:R->R;D:R->Prop) (continuity f) -> (ouvert D) -> (ouvert (image_rec f D)).
Intros; Unfold ouvert in H0; Unfold ouvert; Intros; Assert H2 := (continuity_P1 f x); Elim H2; Intros H3 _; Assert H4 := (H3 (H x)); Unfold voisinage image_rec; Unfold image_rec in H1; Assert H5 := (H4 D (H0 (f x) H1)); Elim H5; Intros V0 H6; Elim H6; Intros; Unfold voisinage in H7; Elim H7; Intros del H9; Exists del; Unfold inclus in H9; Unfold inclus; Intros; Apply (H8 ? (H9 ? H10)).
Qed.

(* Caract�risation compl�te des fonctions continues : *)
(* une fonction est continue ssi l'image r�ciproque de tout ouvert est un ouvert *)
Lemma continuity_P3 : (f:R->R) (continuity f) <-> (D:R->Prop) (ouvert D)->(ouvert (image_rec f D)).
Intros; Split.
Intros; Apply continuity_P2; Assumption.
Intros; Unfold continuity; Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Simpl; Unfold R_dist; Intros; Cut (ouvert (Disque (f x) (mkposreal ? H0))).
Intro; Assert H2 := (H ? H1).
Unfold ouvert image_rec in H2; Cut (Disque (f x) (mkposreal ? H0) (f x)).
Intro; Assert H4 := (H2 ? H3).
Unfold voisinage in H4; Elim H4; Intros del H5.
Exists (pos del); Split.
Apply (cond_pos del).
Intros; Unfold inclus in H5; Apply H5; Elim H6; Intros; Apply H8.
Unfold Disque; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Apply H0.
Apply disque_P1.
Qed.

(* R est s�par� *)
Theorem Rsepare : (x,y:R) ``x<>y``->(EXT V:R->Prop | (EXT W:R->Prop | (voisinage V x)/\(voisinage W y)/\~(EXT y:R | (intersection_domaine V W y)))).
Intros x y Hsep; Pose D := ``(Rabsolu (x-y))``.
Cut ``0<D/2``.
Intro; Exists (Disque x (mkposreal ? H)).
Exists (Disque y (mkposreal ? H)); Split.
Unfold voisinage; Exists (mkposreal ? H); Unfold inclus; Tauto.
Split.
Unfold voisinage; Exists (mkposreal ? H); Unfold inclus; Tauto.
Red; Intro; Elim H0; Intros; Unfold intersection_domaine in H1; Elim H1; Intros.
Cut ``D<D``.
Intro; Elim (Rlt_antirefl ? H4).
Change ``(Rabsolu (x-y))<D``; Apply Rle_lt_trans with ``(Rabsolu (x-x0))+(Rabsolu (x0-y))``.
Replace ``x-y`` with ``(x-x0)+(x0-y)``; [Apply Rabsolu_triang | Ring].
Rewrite (double_var D); Apply Rplus_lt.
Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply H2.
Apply H3.
Unfold Rdiv; Apply Rmult_lt_pos.
Unfold D; Apply Rabsolu_pos_lt; Apply (Rminus_eq_contra ? ? Hsep).
Apply Rlt_Rinv; Sup0.
Qed.

(* Ce type d�crit les familles de domaines index�es par un domaine *)
Record famille : Type := mkfamille {
  ind : R->Prop;
  f :> R->R->Prop;
  cond_fam : (x:R)(EXT y:R|(f x y))->(ind x) }.

Definition famille_ouvert [f:famille] : Prop := (x:R) (ouvert (f x)).

(* Liste de r�els *)
Inductive Rlist : Type :=
| nil : Rlist
| cons : R -> Rlist -> Rlist.

Fixpoint In [x:R;l:Rlist] : Prop :=
Cases l of
| nil => False
| (cons a l') => ``x==a``\/(In x l') end.

Definition domaine_fini [D:R->Prop] : Prop := (EXT l:Rlist | (x:R)(D x)<->(In x l)).

Fixpoint longueur [l:Rlist] : nat :=
Cases l of
| nil => O
| (cons a l') => (S (longueur l')) end.

(* Cette fonction renvoie le maximum des �l�ments d'une liste non vide *)
Fixpoint MaxRlist [l:Rlist] : R :=
 Cases l of
 | nil => R0 (* valeur de retour si la liste de d�part est vide *)
 | (cons a l1) => 
   Cases l1 of
   | nil => a
   | (cons a' l2) => (Rmax a (MaxRlist l1)) 
   end
end.

Fixpoint MinRlist [l:Rlist] : R :=
Cases l of
 | nil => R1 (* valeur de retour si la liste de d�part est vide *)
 | (cons a l1) => 
   Cases l1 of
   | nil => a
   | (cons a' l2) => (Rmin a (MinRlist l1)) 
   end
end.

Definition famille_finie [f:famille] : Prop := (domaine_fini (ind f)).

Definition recouvrement [D:R->Prop;f:famille] : Prop := (x:R) (D x)->(EXT y:R | (f y x)).

Definition recouvrement_ouvert [D:R->Prop;f:famille] : Prop := (recouvrement D f)/\(famille_ouvert f).

Definition recouvrement_fini [D:R->Prop;f:famille] : Prop := (recouvrement D f)/\(famille_finie f).

Lemma restriction_famille : (f:famille;D:R->Prop) (x:R)(EXT y:R|([z1:R][z2:R](f z1 z2)/\(D z1) x y))->(intersection_domaine (ind f) D x).
Intros; Elim H; Intros; Unfold intersection_domaine; Elim H0; Intros; Split.
Apply (cond_fam f0); Exists x0; Assumption.
Assumption.
Qed.

Definition famille_restreinte [f:famille;D:R->Prop] : famille := (mkfamille (intersection_domaine (ind f) D) [x:R][y:R](f x y)/\(D x) (restriction_famille f D)).

Definition compact [X:R->Prop] : Prop := (f:famille) (recouvrement_ouvert X f) -> (EXT D:R->Prop | (recouvrement_fini X (famille_restreinte f D))).

(* Un sous-ensemble d'une famille d'ouverts est une famille d'ouverts *)
Lemma famille_P1 : (f:famille;D:R->Prop) (famille_ouvert f) -> (famille_ouvert (famille_restreinte f D)).
Unfold famille_ouvert; Intros; Unfold famille_restreinte; Simpl; Assert H0 := (classic (D x)).
Elim H0; Intro.
Cut (ouvert (f0 x))->(ouvert [y:R](f0 x y)/\(D x)).
Intro; Apply H2; Apply H.
Unfold ouvert; Unfold voisinage; Intros; Elim H3; Intros; Assert H6 := (H2 ? H4); Elim H6; Intros; Exists x1; Unfold inclus; Intros; Split.
Apply (H7 ? H8).
Assumption.
Cut (ouvert [y:R]False) -> (ouvert [y:R](f0 x y)/\(D x)).
Intro; Apply H2; Apply ouvert_P4.
Unfold ouvert; Unfold voisinage; Intros; Elim H3; Intros; Elim H1; Assumption.
Qed.

Definition bornee [D:R->Prop] : Prop := (EXT m:R | (EXT M:R | (x:R)(D x)->``m<=x<=M``)).

Lemma MaxRlist_P1 : (l:Rlist;x:R) (In x l)->``x<=(MaxRlist l)``.
Intros; Induction l.
Simpl in H; Elim H.
Induction l.
Simpl in H; Elim H; Intro.
Simpl; Right; Assumption.
Elim H0.
Replace (MaxRlist (cons r (cons r0 l))) with (Rmax r (MaxRlist (cons r0 l))).
Simpl in H; Decompose [or] H.
Rewrite H0; Apply RmaxLess1.
Unfold Rmax; Case (total_order_Rle r (MaxRlist (cons r0 l))); Intro.
Apply Hrecl; Simpl; Tauto.
Apply Rle_trans with (MaxRlist (cons r0 l)); [Apply Hrecl; Simpl; Tauto | Left; Auto with real].
Unfold Rmax; Case (total_order_Rle r (MaxRlist (cons r0 l))); Intro.
Apply Hrecl; Simpl; Tauto.
Apply Rle_trans with (MaxRlist (cons r0 l)); [Apply Hrecl; Simpl; Tauto | Left; Auto with real].
Reflexivity.
Qed.

Lemma ouvert_P6 : (D1,D2:R->Prop) (ouvert D1) -> D1 =_D D2 -> (ouvert D2).
Unfold ouvert; Unfold voisinage; Intros.
Unfold eq_Dom in H0; Elim H0; Intros.
Assert H4 := (H ? (H3 ? H1)).
Elim H4; Intros.
Exists x0; Apply inclus_trans with D1; Assumption.
Qed.

(* Les parties compactes de R sont born�es *)
Lemma compact_P1 : (X:R->Prop) (compact X) -> (bornee X).
Intros; Unfold compact in H; Pose D := [x:R]True; Pose g := [x:R][y:R]``(Rabsolu y)<x``; Cut (x:R)(EXT y|(g x y))->True; [Intro | Intro; Trivial].
Pose f0 := (mkfamille D g H0); Assert H1 := (H f0); Cut (recouvrement_ouvert X f0).
Intro; Assert H3 := (H1 H2); Elim H3; Intros D' H4; Unfold recouvrement_fini in H4; Elim H4; Intros; Unfold famille_finie in H6; Unfold domaine_fini in H6; Elim H6; Intros l H7; Unfold bornee; Pose r := (MaxRlist l).
Exists ``-r``; Exists r; Intros.
Unfold recouvrement in H5; Assert H9 := (H5 ? H8); Elim H9; Intros; Unfold famille_restreinte in H10; Simpl in H10; Elim H10; Intros; Assert H13 := (H7 x0); Simpl in H13; Cut (intersection_domaine D D' x0).
Elim H13; Clear H13; Intros.
Assert H16 := (H13 H15); Unfold g in H11; Split.
Cut ``x0<=r``.
Intro; Cut ``(Rabsolu x)<r``.
Intro; Assert H19 := (Rabsolu_def2 x r H18); Elim H19; Intros; Left; Assumption.
Apply Rlt_le_trans with x0; Assumption.
Apply (MaxRlist_P1 l x0 H16).
Cut ``x0<=r``.
Intro; Apply Rle_trans with (Rabsolu x).
Apply Rle_Rabsolu.
Apply Rle_trans with x0.
Left; Apply H11.
Assumption.
Apply (MaxRlist_P1 l x0 H16).
Unfold intersection_domaine D; Tauto.
Unfold recouvrement_ouvert; Split.
Unfold recouvrement; Intros; Simpl; Exists ``(Rabsolu x)+1``; Unfold g; Pattern 1 (Rabsolu x); Rewrite <- Rplus_Or; Apply Rlt_compatibility; Apply Rlt_R0_R1.
Unfold famille_ouvert; Intro; Case (total_order R0 x); Intro.
Apply ouvert_P6 with (Disque R0 (mkposreal ? H2)).
Apply disque_P1.
Unfold eq_Dom; Unfold f0; Simpl; Unfold g Disque; Split.
Unfold inclus; Intros; Unfold Rminus in H3; Rewrite Ropp_O in H3; Rewrite Rplus_Or in H3; Apply H3.
Unfold inclus; Intros; Unfold Rminus; Rewrite Ropp_O; Rewrite Rplus_Or; Apply H3.
Apply ouvert_P6 with [x:R]False.
Apply ouvert_P4.
Unfold eq_Dom; Split.
Unfold inclus; Intros; Elim H3.
Unfold inclus f0; Simpl; Unfold g; Intros; Elim H2; Intro; [Rewrite <- H4 in H3; Assert H5 := (Rabsolu_pos x0); Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? H5 H3)) | Assert H6 := (Rabsolu_pos x0); Assert H7 := (Rlt_trans ? ? ? H3 H4); Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? H6 H7))].
Qed.

Fixpoint AbsList [l:Rlist] : R->Rlist :=
[x:R] Cases l of
| nil => nil
| (cons a l') => (cons ``(Rabsolu (a-x))/2`` (AbsList l' x))
end.

Lemma MinRlist_P1 : (l:Rlist;x:R) (In x l)->``(MinRlist l)<=x``.
Intros; Induction l.
Simpl in H; Elim H.
Induction l.
Simpl in H; Elim H; Intro.
Simpl; Right; Symmetry; Assumption.
Elim H0.
Replace (MinRlist (cons r (cons r0 l))) with (Rmin r (MinRlist (cons r0 l))).
Simpl in H; Decompose [or] H.
Rewrite H0; Apply Rmin_l.
Unfold Rmin; Case (total_order_Rle r (MinRlist (cons r0 l))); Intro.
Apply Rle_trans with (MinRlist (cons r0 l)).
Assumption.
Apply Hrecl; Simpl; Tauto.
Apply Hrecl; Simpl; Tauto.
Apply Rle_trans with (MinRlist (cons r0 l)).
Apply Rmin_r.
Apply Hrecl; Simpl; Tauto.
Reflexivity.
Qed.

Lemma AbsList_P1 : (l:Rlist;x,y:R) (In y l) -> (In ``(Rabsolu (y-x))/2`` (AbsList l x)).
Intros; Induction l.
Elim H.
Simpl; Simpl in H; Elim H; Intro.
Left; Rewrite H0; Reflexivity.
Right; Apply Hrecl; Assumption.
Qed.

Lemma MinRlist_P2 : (l:Rlist) ((y:R)(In y l)->``0<y``)->``0<(MinRlist l)``.
Intros; Induction l.
Apply Rlt_R0_R1.
Induction l.
Simpl; Apply H; Simpl; Tauto.
Replace (MinRlist (cons r (cons r0 l))) with (Rmin r (MinRlist (cons r0 l))).
Unfold Rmin; Case (total_order_Rle r (MinRlist (cons r0 l))); Intro.
Apply H; Simpl; Tauto.
Apply Hrecl; Intros; Apply H; Simpl; Simpl in H0; Tauto.
Reflexivity.
Qed.

Lemma AbsList_P2 : (l:Rlist;x,y:R) (In y (AbsList l x)) -> (EXT z : R | (In z l)/\``y==(Rabsolu (z-x))/2``).
Intros; Induction l.
Elim H.
Elim H; Intro.
Exists r; Split.
Simpl; Tauto.
Assumption.
Assert H1 := (Hrecl H0); Elim H1; Intros; Elim H2; Clear H2; Intros; Exists x0; Simpl; Simpl in H2; Tauto.
Qed.

(* Les parties compactes de R sont ferm�es *)
Lemma compact_P2 : (X:R->Prop) (compact X) -> (ferme X).
Intros; Assert H0 := (ferme_P1 X); Elim H0; Clear H0; Intros _ H0; Apply H0; Clear H0.
Unfold eq_Dom; Split.
Apply adherence_P1.
Unfold inclus; Unfold adherence; Unfold point_adherent; Intros; Unfold compact in H; Assert H1 := (classic (X x)); Elim H1; Clear H1; Intro.
Assumption.
Cut (y:R)(X y)->``0<(Rabsolu (y-x))/2``.
Intro; Pose D := X; Pose g := [y:R][z:R]``(Rabsolu (y-z))<(Rabsolu (y-x))/2``/\(D y); Cut (x:R)(EXT y|(g x y))->(D x).
Intro; Pose f0 := (mkfamille D g H3); Assert H4 := (H f0); Cut (recouvrement_ouvert X f0).
Intro; Assert H6 := (H4 H5); Elim H6; Clear H6; Intros D' H6.
Unfold recouvrement_fini in H6; Decompose [and] H6; Unfold recouvrement famille_restreinte in H7; Simpl in H7; Unfold famille_finie famille_restreinte in H8; Simpl in H8; Unfold domaine_fini in H8; Elim H8; Clear H8; Intros l H8; Pose alp := (MinRlist (AbsList l x)); Cut ``0<alp``.
Intro; Assert H10 := (H0 (Disque x (mkposreal ? H9))); Cut (voisinage (Disque x (mkposreal alp H9)) x).
Intro; Assert H12 := (H10 H11); Elim H12; Clear H12; Intros y H12; Unfold intersection_domaine in H12; Elim H12; Clear H12; Intros; Assert H14 := (H7 ? H13); Elim H14; Clear H14; Intros y0 H14; Elim H14; Clear H14; Intros; Unfold g in H14; Elim H14; Clear H14; Intros; Unfold Disque in H12; Simpl in H12; Cut ``alp<=(Rabsolu (y0-x))/2``.
Intro; Assert H18 := (Rlt_le_trans ? ? ? H12 H17); Cut ``(Rabsolu (y0-x))<(Rabsolu (y0-x))``.
Intro; Elim (Rlt_antirefl ? H19).
Apply Rle_lt_trans with ``(Rabsolu (y0-y))+(Rabsolu (y-x))``.
Replace ``y0-x`` with ``(y0-y)+(y-x)``; [Apply Rabsolu_triang | Ring].
Rewrite (double_var ``(Rabsolu (y0-x))``); Apply Rplus_lt; Assumption.
Apply (MinRlist_P1 (AbsList l x) ``(Rabsolu (y0-x))/2``); Apply AbsList_P1; Elim (H8 y0); Clear H8; Intros; Apply H8; Unfold intersection_domaine; Split; Assumption.
Assert H11 := (disque_P1 x (mkposreal alp H9)); Unfold ouvert in H11; Apply H11.
Unfold Disque; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Apply H9.
Unfold alp; Apply MinRlist_P2; Intros; Assert H10 := (AbsList_P2 ? ? ? H9); Elim H10; Clear H10; Intros z H10; Elim H10; Clear H10; Intros; Rewrite H11; Apply H2; Elim (H8 z); Clear H8; Intros; Assert H13 := (H12 H10); Unfold intersection_domaine D in H13; Elim H13; Clear H13; Intros; Assumption.
Unfold recouvrement_ouvert; Split.
Unfold recouvrement; Intros; Exists x0; Simpl; Unfold g; Split.
Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Unfold Rminus in H2; Apply (H2 ? H5).
Apply H5.
Unfold famille_ouvert; Intro; Simpl; Unfold g; Elim (classic (D x0)); Intro.
Apply ouvert_P6 with (Disque x0 (mkposreal ? (H2 ? H5))).
Apply disque_P1.
Unfold eq_Dom; Split.
Unfold inclus Disque; Simpl; Intros; Split.
Rewrite <- (Rabsolu_Ropp ``x0-x1``); Rewrite Ropp_distr2; Apply H6.
Apply H5.
Unfold inclus Disque; Simpl; Intros; Elim H6; Intros; Rewrite <- (Rabsolu_Ropp ``x1-x0``); Rewrite Ropp_distr2; Apply H7.
Apply ouvert_P6 with [z:R]False.
Apply ouvert_P4.
Unfold eq_Dom; Split.
Unfold inclus; Intros; Elim H6.
Unfold inclus; Intros; Elim H6; Intros; Elim H5; Assumption.
Intros; Elim H3; Intros; Unfold g in H4; Elim H4; Clear H4; Intros _ H4; Apply H4.
Intros; Unfold Rdiv; Apply Rmult_lt_pos.
Apply Rabsolu_pos_lt; Apply Rminus_eq_contra; Red; Intro; Rewrite H3 in H2; Elim H1; Apply H2.
Apply Rlt_Rinv; Sup0.
Qed.

(* La partie vide est compacte *)
Lemma compact_EMP : (compact [_:R]False).
Unfold compact; Intros; Exists [x:R]False; Unfold recouvrement_fini; Split.
Unfold recouvrement; Intros; Elim H0.
Unfold famille_finie; Unfold domaine_fini; Exists nil; Intro.
Split.
Simpl; Unfold intersection_domaine; Intros; Elim H0.
Elim H0; Clear H0; Intros _ H0; Elim H0.
Simpl; Intro; Elim H0.
Qed.

Lemma compact_eqDom : (X1,X2:R->Prop) (compact X1) -> X1 =_D X2 -> (compact X2).
Unfold compact; Intros; Unfold eq_Dom in H0; Elim H0; Clear H0; Unfold inclus; Intros; Assert H3 : (recouvrement_ouvert X1 f0).
Unfold recouvrement_ouvert; Unfold recouvrement_ouvert in H1; Elim H1; Clear H1; Intros; Split.
Unfold recouvrement in H1; Unfold recouvrement; Intros; Apply (H1 ? (H0 ? H4)).
Apply H3.
Elim (H ? H3); Intros D H4; Exists D; Unfold recouvrement_fini; Unfold recouvrement_fini in H4; Elim H4; Intros; Split.
Unfold recouvrement in H5; Unfold recouvrement; Intros; Apply (H5 ? (H2 ? H7)).
Apply H6.
Qed.

(* Lemme de Borel-Lebesgue *)
Lemma compact_P3 : (a,b:R) (compact [c:R]``a<=c<=b``).
Intros; Case (total_order_Rle a b); Intro.
Unfold compact; Intros; Pose A := [x:R]``a<=x<=b``/\(EXT D:R->Prop | (recouvrement_fini [c:R]``a <= c <= x`` (famille_restreinte f0 D))); Cut (A a).
Intro; Cut (bound A).
Intro; Cut (EXT a0:R | (A a0)).
Intro; Assert H3 := (complet A H1 H2); Elim H3; Clear H3; Intros m H3; Unfold is_lub in H3; Cut ``a<=m<=b``.
Intro; Unfold recouvrement_ouvert in H; Elim H; Clear H; Intros; Unfold recouvrement in H; Assert H6 := (H m H4); Elim H6; Clear H6; Intros y0 H6; Unfold famille_ouvert in H5; Assert H7 := (H5 y0); Unfold ouvert in H7; Assert H8 := (H7 m H6); Unfold voisinage in H8; Elim H8; Clear H8; Intros eps H8; Cut (EXT x:R | (A x)/\``m-eps<x<=m``).
Intro; Elim H9; Clear H9; Intros x H9; Elim H9; Clear H9; Intros; Case (Req_EM m b); Intro.
Rewrite H11 in H10; Rewrite H11 in H8; Unfold A in H9; Elim H9; Clear H9; Intros; Elim H12; Clear H12; Intros Dx H12; Pose Db := [x:R](Dx x)\/x==y0; Exists Db; Unfold recouvrement_fini; Split.
Unfold recouvrement; Unfold recouvrement_fini in H12; Elim H12; Clear H12; Intros; Unfold recouvrement in H12; Case (total_order_Rle x0 x); Intro.
Cut ``a<=x0<=x``.
Intro; Assert H16 := (H12 x0 H15); Elim H16; Clear H16; Intros; Exists x1; Simpl in H16; Simpl; Unfold Db; Elim H16; Clear H16; Intros; Split; [Apply H16 | Left; Apply H17].
Split.
Elim H14; Intros; Assumption.
Assumption.
Exists y0; Simpl; Split.
Apply H8; Unfold Disque; Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Rewrite Rabsolu_right.
Apply Rlt_trans with ``b-x``.
Unfold Rminus; Apply Rlt_compatibility; Apply Rlt_Ropp; Auto with real.
Elim H10; Intros H15 _; Apply Rlt_anti_compatibility with ``x-eps``; Replace ``x-eps+(b-x)`` with ``b-eps``; [Replace ``x-eps+eps`` with x; [Apply H15 | Ring] | Ring].
Apply Rge_minus; Apply Rle_sym1; Elim H14; Intros _ H15; Apply H15.
Unfold Db; Right; Reflexivity.
Unfold famille_finie; Unfold domaine_fini; Unfold recouvrement_fini in H12; Elim H12; Clear H12; Intros; Unfold famille_finie in H13; Unfold domaine_fini in H13; Elim H13; Clear H13; Intros l H13; Exists (cons y0 l); Intro; Split.
Intro; Simpl in H14; Unfold intersection_domaine in H14; Elim (H13 x0); Clear H13; Intros; Case (Req_EM x0 y0); Intro.
Simpl; Left; Apply H16.
Simpl; Right; Apply H13.
Simpl; Unfold intersection_domaine; Unfold Db in H14; Decompose [and or] H14.
Split; Assumption.
Elim H16; Assumption.
Intro; Simpl in H14; Elim H14; Intro; Simpl; Unfold intersection_domaine.
Split.
Apply (cond_fam f0); Rewrite H15; Exists m; Apply H6.
Unfold Db; Right; Assumption.
Simpl; Unfold intersection_domaine; Elim (H13 x0).
Intros _ H16; Assert H17 := (H16 H15); Simpl in H17; Unfold intersection_domaine in H17; Split.
Elim H17; Intros; Assumption.
Unfold Db; Left; Elim H17; Intros; Assumption.
Pose m' := (Rmin ``m+eps/2`` b); Cut (A m').
Intro; Elim H3; Intros; Unfold is_upper_bound in H13; Assert H15 := (H13 m' H12); Cut ``m<m'``.
Intro; Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? H15 H16)).
Unfold m'; Unfold Rmin; Case (total_order_Rle ``m+eps/2`` b); Intro.
Pattern 1 m; Rewrite <- Rplus_Or; Apply Rlt_compatibility; Unfold Rdiv; Apply Rmult_lt_pos; [Apply (cond_pos eps) | Apply Rlt_Rinv; Sup0].
Elim H4; Intros.
Elim H17; Intro.
Assumption.
Elim H11; Assumption.
Unfold A; Split.
Split.
Apply Rle_trans with m.
Elim H4; Intros; Assumption.
Unfold m'; Unfold Rmin; Case (total_order_Rle ``m+eps/2`` b); Intro.
Pattern 1 m; Rewrite <- Rplus_Or; Apply Rle_compatibility; Left; Unfold Rdiv; Apply Rmult_lt_pos; [Apply (cond_pos eps) | Apply Rlt_Rinv; Sup0].
Elim H4; Intros.
Elim H13; Intro.
Assumption.
Elim H11; Assumption.
Unfold m'; Apply Rmin_r.
Unfold A in H9; Elim H9; Clear H9; Intros; Elim H12; Clear H12; Intros Dx H12; Pose Db := [x:R](Dx x)\/x==y0; Exists Db; Unfold recouvrement_fini; Split.
Unfold recouvrement; Unfold recouvrement_fini in H12; Elim H12; Clear H12; Intros; Unfold recouvrement in H12; Case (total_order_Rle x0 x); Intro.
Cut ``a<=x0<=x``.
Intro; Assert H16 := (H12 x0 H15); Elim H16; Clear H16; Intros; Exists x1; Simpl in H16; Simpl; Unfold Db.
Elim H16; Clear H16; Intros; Split; [Apply H16 | Left; Apply H17].
Elim H14; Intros; Split; Assumption.
Exists y0; Simpl; Split.
Apply H8; Unfold Disque; Unfold Rabsolu; Case (case_Rabsolu ``x0-m``); Intro.
Rewrite Ropp_distr2; Apply Rlt_trans with ``m-x``.
Unfold Rminus; Apply Rlt_compatibility; Apply Rlt_Ropp; Auto with real.
Apply Rlt_anti_compatibility with ``x-eps``; Replace ``x-eps+(m-x)`` with ``m-eps``.
Replace ``x-eps+eps`` with x.
Elim H10; Intros; Assumption.
Ring.
Ring.
Apply Rle_lt_trans with ``m'-m``.
Unfold Rminus; Do 2 Rewrite <- (Rplus_sym ``-m``); Apply Rle_compatibility; Elim H14; Intros; Assumption.
Apply Rlt_anti_compatibility with m; Replace ``m+(m'-m)`` with m'.
Apply Rle_lt_trans with ``m+eps/2``.
Unfold m'; Apply Rmin_l.
Apply Rlt_compatibility; Apply Rlt_monotony_contra with ``2``.
Sup0.
Unfold Rdiv; Rewrite <- (Rmult_sym ``/2``); Rewrite <- Rmult_assoc; Rewrite <- Rinv_r_sym.
Rewrite Rmult_1l; Pattern 1 (pos eps); Rewrite <- Rplus_Or; Rewrite double; Apply Rlt_compatibility; Apply (cond_pos eps).
DiscrR.
Ring.
Unfold Db; Right; Reflexivity.
Unfold famille_finie; Unfold domaine_fini; Unfold recouvrement_fini in H12; Elim H12; Clear H12; Intros; Unfold famille_finie in H13; Unfold domaine_fini in H13; Elim H13; Clear H13; Intros l H13; Exists (cons y0 l); Intro; Split.
Intro; Simpl in H14; Unfold intersection_domaine in H14; Elim (H13 x0); Clear H13; Intros; Case (Req_EM x0 y0); Intro.
Simpl; Left; Apply H16.
Simpl; Right; Apply H13; Simpl; Unfold intersection_domaine; Unfold Db in H14; Decompose [and or] H14.
Split; Assumption.
Elim H16; Assumption.
Intro; Simpl in H14; Elim H14; Intro; Simpl; Unfold intersection_domaine.
Split.
Apply (cond_fam f0); Rewrite H15; Exists m; Apply H6.
Unfold Db; Right; Assumption.
Elim (H13 x0); Intros _ H16.
Assert H17 := (H16 H15).
Simpl in H17.
Unfold intersection_domaine in H17.
Split.
Elim H17; Intros; Assumption.
Unfold Db; Left; Elim H17; Intros; Assumption.
Elim (classic (EXT x:R | (A x)/\``m-eps < x <= m``)); Intro.
Assumption.
Elim H3; Intros; Cut (is_upper_bound A ``m-eps``).
Intro; Assert H13 := (H11 ? H12); Cut ``m-eps<m``.
Intro; Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? H13 H14)).
Pattern 2 m; Rewrite <- Rplus_Or; Unfold Rminus; Apply Rlt_compatibility; Apply Ropp_Rlt; Rewrite Ropp_Ropp; Rewrite Ropp_O; Apply (cond_pos eps).
Pose P := [n:R](A n)/\``m-eps<n<=m``; Assert H12 := (not_ex_all_not ? P H9); Unfold P in H12; Unfold is_upper_bound; Intros; Assert H14 := (not_and_or ? ? (H12 x)); Elim H14; Intro.
Elim H15; Apply H13.
Elim (not_and_or ? ? H15); Intro.
Case (total_order_Rle x ``m-eps``); Intro.
Assumption.
Elim H16; Auto with real.
Unfold is_upper_bound in H10; Assert H17 := (H10 x H13); Elim H16; Apply H17.
Elim H3; Clear H3; Intros.
Unfold is_upper_bound in H3.
Split.
Apply (H3 ? H0).
Apply (H4 b); Unfold is_upper_bound; Intros; Unfold A in H5; Elim H5; Clear H5; Intros H5 _; Elim H5; Clear H5; Intros _ H5; Apply H5.
Exists a; Apply H0.
Unfold bound; Exists b; Unfold is_upper_bound; Intros; Unfold A in H1; Elim H1; Clear H1; Intros H1 _; Elim H1; Clear H1; Intros _ H1; Apply H1.
Unfold A; Split.
Split; [Right; Reflexivity | Apply r].
Unfold recouvrement_ouvert in H; Elim H; Clear H; Intros; Unfold recouvrement in H; Cut ``a<=a<=b``.
Intro; Elim (H ? H1); Intros y0 H2; Pose D':=[x:R]x==y0; Exists D'; Unfold recouvrement_fini; Split.
Unfold recouvrement; Simpl; Intros; Cut x==a.
Intro; Exists y0; Split.
Rewrite H4; Apply H2.
Unfold D'; Reflexivity.
Elim H3; Intros; Apply Rle_antisym; Assumption.
Unfold famille_finie; Unfold domaine_fini; Exists (cons y0 nil); Intro; Split.
Simpl; Unfold intersection_domaine; Intro; Elim H3; Clear H3; Intros; Unfold D' in H4; Left; Apply H4.
Simpl; Unfold intersection_domaine; Intro; Elim H3; Intro.
Split; [Rewrite H4; Apply (cond_fam f0); Exists a; Apply H2 | Apply H4].
Elim H4.
Split; [Right; Reflexivity | Apply r].
Apply compact_eqDom with [c:R]False.
Apply compact_EMP.
Unfold eq_Dom; Split.
Unfold inclus; Intros; Elim H.
Unfold inclus; Intros; Elim H; Clear H; Intros; Assert H1 := (Rle_trans ? ? ? H H0); Elim n; Apply H1.
Qed.

Lemma compact_P4 : (X,F:R->Prop) (compact X) -> (ferme F) -> (inclus F X) -> (compact F).
Unfold compact; Intros; Elim (classic (EXT z:R | (F z))); Intro Hyp_F_NE.
Pose D := (ind f0); Pose g := (f f0); Unfold ferme in H0.
Pose g' := [x:R][y:R](f0 x y)\/((complementaire F y)/\(D x)).
Pose D' := D.
Cut (x:R)(EXT y:R | (g' x y))->(D' x).
Intro; Pose f' := (mkfamille D' g' H3); Cut (recouvrement_ouvert X f').
Intro; Elim (H ? H4); Intros DX H5; Exists DX.
Unfold recouvrement_fini; Unfold recouvrement_fini in H5; Elim H5; Clear H5; Intros.
Split.
Unfold recouvrement; Unfold recouvrement in H5; Intros.
Elim (H5 ? (H1 ? H7)); Intros y0 H8; Exists y0; Simpl in H8; Simpl; Elim H8; Clear H8; Intros.
Split.
Unfold g' in H8; Elim H8; Intro.
Apply H10.
Elim H10; Intros H11 _; Unfold complementaire in H11; Elim H11; Apply H7.
Apply H9.
Unfold famille_finie; Unfold domaine_fini; Unfold famille_finie in H6; Unfold domaine_fini in H6; Elim H6; Clear H6; Intros l H6; Exists l; Intro; Assert H7 := (H6 x); Elim H7; Clear H7; Intros.
Split.
Intro; Apply H7; Simpl; Unfold intersection_domaine; Simpl in H9; Unfold intersection_domaine in H9; Unfold D'; Apply H9.
Intro; Assert H10 := (H8 H9); Simpl in H10; Unfold intersection_domaine in H10; Simpl; Unfold intersection_domaine; Unfold D' in H10; Apply H10.
Unfold recouvrement_ouvert; Unfold recouvrement_ouvert in H2; Elim H2; Clear H2; Intros.
Split.
Unfold recouvrement; Unfold recouvrement in H2; Intros.
Elim (classic (F x)); Intro.
Elim (H2 ? H6); Intros y0 H7; Exists y0; Simpl; Unfold g'; Left; Assumption.
Cut (EXT z:R | (D z)).
Intro; Elim H7; Clear H7; Intros x0 H7; Exists x0; Simpl; Unfold g'; Right.
Split.
Unfold complementaire; Apply H6.
Apply H7.
Elim Hyp_F_NE; Intros z0 H7.
Assert H8 := (H2 ? H7).
Elim H8; Clear H8; Intros t H8; Exists t; Apply (cond_fam f0); Exists z0; Apply H8.
Unfold famille_ouvert; Intro; Simpl; Unfold g'; Elim (classic (D x)); Intro.
Apply ouvert_P6 with (union_domaine (f0 x) (complementaire F)).
Apply ouvert_P2.
Unfold famille_ouvert in H4; Apply H4.
Apply H0.
Unfold eq_Dom; Split.
Unfold inclus union_domaine complementaire; Intros.
Elim H6; Intro; [Left; Apply H7 | Right; Split; Assumption].
Unfold inclus union_domaine complementaire; Intros.
Elim H6; Intro; [Left; Apply H7 | Right; Elim H7; Intros; Apply H8].
Apply ouvert_P6 with (f0 x).
Unfold famille_ouvert in H4; Apply H4.
Unfold eq_Dom; Split.
Unfold inclus complementaire; Intros; Left; Apply H6.
Unfold inclus complementaire; Intros.
Elim H6; Intro.
Apply H7.
Elim H7; Intros _ H8; Elim H5; Apply H8.
Intros; Elim H3; Intros y0 H4; Unfold g' in H4; Elim H4; Intro.
Apply (cond_fam f0); Exists y0; Apply H5.
Elim H5; Clear H5; Intros _ H5; Apply H5.
(* Cas ou F est l'ensemble vide *)
Cut (compact F).
Intro; Apply (H3 f0 H2).
Apply compact_eqDom with [_:R]False.
Apply compact_EMP.
Unfold eq_Dom; Split.
Unfold inclus; Intros; Elim H3.
Assert H3 := (not_ex_all_not ? ? Hyp_F_NE); Unfold inclus; Intros; Elim (H3 x); Apply H4.
Qed.

(* Les parties ferm�es et born�es sont compactes *)
Lemma compact_P5 : (X:R->Prop) (ferme X)->(bornee X)->(compact X).
Intros; Unfold bornee in H0.
Elim H0; Clear H0; Intros m H0.
Elim H0; Clear H0; Intros M H0.
Assert H1 := (compact_P3 m M).
Apply (compact_P4 [c:R]``m<=c<=M`` X H1 H H0).
Qed.

(* Les compacts de R sont les ferm�s born�s *)
Lemma compact_carac : (X:R->Prop) (compact X)<->(ferme X)/\(bornee X).
Intro; Split.
Intro; Split; [Apply (compact_P2 ? H) | Apply (compact_P1 ? H)].
Intro; Elim H; Clear H; Intros; Apply (compact_P5 ? H H0).
Qed.

Definition image_dir [f:R->R;D:R->Prop] : R->Prop := [x:R](EXT y:R | x==(f y)/\(D y)).

(* L'image d'un compact par une application continue est un compact *)
Lemma continuity_compact : (f:R->R;X:R->Prop) ((x:R)(continuity_pt f x)) -> (compact X) -> (compact (image_dir f X)).
Unfold compact; Intros; Unfold recouvrement_ouvert in H1.
Elim H1; Clear H1; Intros.
Pose D := (ind f1).
Pose g := [x:R][y:R](image_rec f0 (f1 x) y).
Cut (x:R)(EXT y:R | (g x y))->(D x).
Intro; Pose f' := (mkfamille D g H3).
Cut (recouvrement_ouvert X f').
Intro; Elim (H0 f' H4); Intros D' H5; Exists D'.
Unfold recouvrement_fini in H5; Elim H5; Clear H5; Intros; Unfold recouvrement_fini; Split.
Unfold recouvrement image_dir; Simpl; Unfold recouvrement in H5; Intros; Elim H7; Intros y H8; Elim H8; Intros; Assert H11 := (H5 ? H10); Simpl in H11; Elim H11; Intros z H12; Exists z; Unfold g in H12; Unfold image_rec in H12; Rewrite H9; Apply H12.
Unfold famille_finie in H6; Unfold domaine_fini in H6; Unfold famille_finie; Unfold domaine_fini; Elim H6; Intros l H7; Exists l; Intro; Elim (H7 x); Intros; Split; Intro.
Apply H8; Simpl in H10; Simpl; Apply H10.
Apply (H9 H10).
Unfold recouvrement_ouvert; Split.
Unfold recouvrement; Intros; Simpl; Unfold recouvrement in H1; Unfold image_dir in H1; Unfold g; Unfold image_rec; Apply H1.
Exists x; Split; [Reflexivity | Apply H4].
Unfold famille_ouvert; Unfold famille_ouvert in H2; Intro; Simpl; Unfold g; Cut ([y:R](image_rec f0 (f1 x) y))==(image_rec f0 (f1 x)).
Intro; Rewrite H4.
Apply (continuity_P2 f0 (f1 x) H (H2 x)).
Reflexivity.
Intros; Apply (cond_fam f1); Unfold g in H3; Unfold image_rec in H3; Elim H3; Intros; Exists (f0 x0); Apply H4.
Qed.

Lemma Rlt_Rminus : (a,b:R) ``a<b`` -> ``0<b-a``.
Intros; Apply Rlt_anti_compatibility with a; Rewrite Rplus_Or; Replace ``a+(b-a)`` with b; [Assumption | Ring].
Qed.

Lemma prolongement_C0 : (f:R->R;a,b:R) ``a<=b`` -> ((c:R)``a<=c<=b``->(continuity_pt f c)) -> (EXT g:R->R | (continuity g)/\((c:R)``a<=c<=b``->(g c)==(f c))).
Intros; Elim H; Intro.
Pose h := [x:R](Cases (total_order_Rle x a) of
  (leftT _) => (f0 a)
| (rightT _) => (Cases (total_order_Rle x b) of
       (leftT _) => (f0 x)
     | (rightT _) => (f0 b) end) end).
Assert H2 : ``0<b-a``.
Apply Rlt_Rminus; Assumption.
Exists h; Split.
Unfold continuity; Intro; Case (total_order x a); Intro.
Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Simpl; Unfold R_dist; Intros; Exists ``a-x``; Split.
Change ``0<a-x``; Apply Rlt_Rminus; Assumption.
Intros; Elim H5; Clear H5; Intros _ H5; Unfold h.
Case (total_order_Rle x a); Intro.
Case (total_order_Rle x0 a); Intro.
Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Assumption.
Elim n; Left; Apply Rlt_anti_compatibility with ``-x``; Do 2 Rewrite (Rplus_sym ``-x``); Apply Rle_lt_trans with ``(Rabsolu (x0-x))``.
Apply Rle_Rabsolu.
Assumption.
Elim n; Left; Assumption.
Elim H3; Intro.
Assert H5 : ``a<=a<=b``.
Split; [Right; Reflexivity | Left; Assumption].
Assert H6 := (H0 ? H5); Unfold continuity_pt in H6; Unfold continue_in in H6; Unfold limit1_in in H6; Unfold limit_in in H6; Simpl in H6; Unfold R_dist in H6; Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Simpl; Unfold R_dist; Intros; Elim (H6 ? H7); Intros; Exists (Rmin x0 ``b-a``); Split.
Unfold Rmin; Case (total_order_Rle x0 ``b-a``); Intro.
Elim H8; Intros; Assumption.
Change ``0<b-a``; Apply Rlt_Rminus; Assumption.
Intros; Elim H9; Clear H9; Intros _ H9; Cut ``x1<b``.
Intro; Unfold h; Case (total_order_Rle x a); Intro.
Case (total_order_Rle x1 a); Intro.
Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Assumption.
Case (total_order_Rle x1 b); Intro.
Elim H8; Intros; Apply H12; Split.
Unfold D_x no_cond; Split.
Trivial.
Red; Intro; Elim n; Right; Symmetry; Assumption.
Apply Rlt_le_trans with (Rmin x0 ``b-a``).
Rewrite H4 in H9; Apply H9.
Apply Rmin_l.
Elim n0; Left; Assumption.
Elim n; Right; Assumption.
Apply Rlt_anti_compatibility with ``-a``; Do 2 Rewrite (Rplus_sym ``-a``); Rewrite H4 in H9; Apply Rle_lt_trans with ``(Rabsolu (x1-a))``.
Apply Rle_Rabsolu.
Apply Rlt_le_trans with ``(Rmin x0 (b-a))``.
Assumption.
Apply Rmin_r.
Case (total_order x b); Intro.
Assert H6 : ``a<=x<=b``.
Split; Left; Assumption.
Assert H7 := (H0 ? H6); Unfold continuity_pt in H7; Unfold continue_in in H7; Unfold limit1_in in H7; Unfold limit_in in H7; Simpl in H7; Unfold R_dist in H7; Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Simpl; Unfold R_dist; Intros; Elim (H7 ? H8); Intros; Elim H9; Clear H9; Intros.
Assert H11 : ``0<x-a``.
Apply Rlt_Rminus; Assumption.
Assert H12 : ``0<b-x``.
Apply Rlt_Rminus; Assumption.
Exists (Rmin x0 (Rmin ``x-a`` ``b-x``)); Split.
Unfold Rmin; Case (total_order_Rle ``x-a`` ``b-x``); Intro.
Case (total_order_Rle x0 ``x-a``); Intro.
Assumption.
Assumption.
Case (total_order_Rle x0 ``b-x``); Intro.
Assumption.
Assumption.
Intros; Elim H13; Clear H13; Intros; Cut ``a<x1<b``.
Intro; Elim H15; Clear H15; Intros; Unfold h; Case (total_order_Rle x a); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r H4)).
Case (total_order_Rle x b); Intro.
Case (total_order_Rle x1 a); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r0 H15)).
Case (total_order_Rle x1 b); Intro.
Apply H10; Split.
Assumption.
Apply Rlt_le_trans with ``(Rmin x0 (Rmin (x-a) (b-x)))``.
Assumption.
Apply Rmin_l.
Elim n1; Left; Assumption.
Elim n0; Left; Assumption.
Split.
Apply Ropp_Rlt; Apply Rlt_anti_compatibility with x; Apply Rle_lt_trans with ``(Rabsolu (x1-x))``.
Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply Rle_Rabsolu.
Apply Rlt_le_trans with ``(Rmin x0 (Rmin (x-a) (b-x)))``.
Assumption.
Apply Rle_trans with ``(Rmin (x-a) (b-x))``.
Apply Rmin_r.
Apply Rmin_l.
Apply Rlt_anti_compatibility with ``-x``; Do 2 Rewrite (Rplus_sym ``-x``); Apply Rle_lt_trans with ``(Rabsolu (x1-x))``.
Apply Rle_Rabsolu.
Apply Rlt_le_trans with ``(Rmin x0 (Rmin (x-a) (b-x)))``.
Assumption.
Apply Rle_trans with ``(Rmin (x-a) (b-x))``; Apply Rmin_r.
Elim H5; Intro.
Assert H7 : ``a<=b<=b``.
Split; [Left; Assumption | Right; Reflexivity].
Assert H8 := (H0 ? H7); Unfold continuity_pt in H8; Unfold continue_in in H8; Unfold limit1_in in H8; Unfold limit_in in H8; Simpl in H8; Unfold R_dist in H8; Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Simpl; Unfold R_dist; Intros; Elim (H8 ? H9); Intros; Exists (Rmin x0 ``b-a``); Split.
Unfold Rmin; Case (total_order_Rle x0 ``b-a``); Intro.
Elim H10; Intros; Assumption.
Change ``0<b-a``; Apply Rlt_Rminus; Assumption.
Intros; Elim H11; Clear H11; Intros _ H11; Cut ``a<x1``.
Intro; Unfold h; Case (total_order_Rle x a); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r H4)).
Case (total_order_Rle x1 a); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r H12)).
Case (total_order_Rle x b); Intro.
Case (total_order_Rle x1 b); Intro.
Rewrite H6; Elim H10; Intros; Elim r0; Intro.
Apply H14; Split.
Unfold D_x no_cond; Split.
Trivial.
Red; Intro; Rewrite <- H16 in H15; Elim (Rlt_antirefl ? H15).
Rewrite H6 in H11; Apply Rlt_le_trans with ``(Rmin x0 (b-a))``.
Apply H11.
Apply Rmin_l.
Rewrite H15; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Assumption.
Rewrite H6; Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Assumption.
Elim n1; Right; Assumption.
Rewrite H6 in H11; Apply Ropp_Rlt; Apply Rlt_anti_compatibility with b; Apply Rle_lt_trans with ``(Rabsolu (x1-b))``.
Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply Rle_Rabsolu.
Apply Rlt_le_trans with ``(Rmin x0 (b-a))``.
Assumption.
Apply Rmin_r.
Unfold continuity_pt; Unfold continue_in; Unfold limit1_in; Unfold limit_in; Simpl; Unfold R_dist; Intros; Exists ``x-b``; Split.
Change ``0<x-b``; Apply Rlt_Rminus; Assumption.
Intros; Elim H8; Clear H8; Intros.
Assert H10 : ``b<x0``.
Apply Ropp_Rlt; Apply Rlt_anti_compatibility with x; Apply Rle_lt_trans with ``(Rabsolu (x0-x))``.
Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Apply Rle_Rabsolu.
Assumption.
Unfold h; Case (total_order_Rle x a); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r H4)).
Case (total_order_Rle x b); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r H6)).
Case (total_order_Rle x0 a); Intro.
Elim (Rlt_antirefl ? (Rlt_trans ? ? ? H1 (Rlt_le_trans ? ? ? H10 r))).
Case (total_order_Rle x0 b); Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? r H10)).
Unfold Rminus; Rewrite Rplus_Ropp_r; Rewrite Rabsolu_R0; Assumption.
Intros; Elim H3; Intros; Unfold h; Case (total_order_Rle c a); Intro.
Elim r; Intro.
Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? H4 H6)).
Rewrite H6; Reflexivity.
Case (total_order_Rle c b); Intro.
Reflexivity.
Elim n0; Assumption.
Exists [_:R](f0 a); Split.
Apply derivable_continuous; Apply (derivable_const (f0 a)).
Intros; Elim H2; Intros; Rewrite H1 in H3; Cut b==c.
Intro; Rewrite <- H5; Rewrite H1; Reflexivity.
Apply Rle_antisym; Assumption.
Qed.

(* f continue sur [a,b] est major�e et atteint sa borne sup�rieure *)
Lemma continuity_ab_maj : (f:R->R;a,b:R) ``a<=b`` -> ((c:R)``a<=c<=b``->(continuity_pt f c)) -> (EXT Mx : R |  ((c:R)``a<=c<=b``->``(f c)<=(f Mx)``)/\``a<=Mx<=b``).
Intros; Cut (EXT g:R->R | (continuity g)/\((c:R)``a<=c<=b``->(g c)==(f0 c))).
Intro HypProl.
Elim HypProl; Intros g Hcont_eq.
Elim Hcont_eq; Clear Hcont_eq; Intros Hcont Heq.
Assert H1 := (compact_P3 a b).
Assert H2 := (continuity_compact g [c:R]``a<=c<=b`` Hcont H1).
Assert H3 := (compact_P2 ? H2).
Assert H4 := (compact_P1 ? H2).
Cut (bound (image_dir g [c:R]``a <= c <= b``)).
Cut (ExT [x:R] ((image_dir g [c:R]``a <= c <= b``) x)).
Intros; Assert H7 := (complet ? H6 H5).
Elim H7; Clear H7; Intros M H7; Cut (image_dir g [c:R]``a <= c <= b`` M).
Intro; Unfold image_dir in H8; Elim H8; Clear H8; Intros Mxx H8; Elim H8; Clear H8; Intros; Exists Mxx; Split.
Intros; Rewrite <- (Heq c H10); Rewrite <- (Heq Mxx H9); Intros; Rewrite <- H8; Unfold is_lub in H7; Elim H7; Clear H7; Intros H7 _; Unfold is_upper_bound in H7; Apply H7; Unfold image_dir; Exists c; Split; [Reflexivity | Apply H10].
Apply H9.
Elim (classic (image_dir g [c:R]``a <= c <= b`` M)); Intro.
Assumption.
Cut (EXT eps:posreal | (y:R)~(intersection_domaine (Disque M eps) (image_dir g [c:R]``a <= c <= b``) y)).
Intro; Elim H9; Clear H9; Intros eps H9; Unfold is_lub in H7; Elim H7; Clear H7; Intros; Cut (is_upper_bound (image_dir g [c:R]``a <= c <= b``) ``M-eps``).
Intro; Assert H12 := (H10 ? H11); Cut ``M-eps<M``.
Intro; Elim (Rlt_antirefl ? (Rle_lt_trans ? ? ? H12 H13)).
Pattern 2 M; Rewrite <- Rplus_Or; Unfold Rminus; Apply Rlt_compatibility; Apply Ropp_Rlt; Rewrite Ropp_O; Rewrite Ropp_Ropp; Apply (cond_pos eps).
Unfold is_upper_bound image_dir; Intros; Cut ``x<=M``.
Intro; Case (total_order_Rle x ``M-eps``); Intro.
Apply r.
Elim (H9 x); Unfold intersection_domaine Disque image_dir; Split.
Rewrite <- Rabsolu_Ropp; Rewrite Ropp_distr2; Rewrite Rabsolu_right.
Apply Rlt_anti_compatibility with ``x-eps``; Replace ``x-eps+(M-x)`` with ``M-eps``.
Replace ``x-eps+eps`` with x.
Auto with real.
Ring.
Ring.
Apply Rge_minus; Apply Rle_sym1; Apply H12.
Apply H11.
Apply H7; Apply H11.
Cut (EXT V:R->Prop | (voisinage V M)/\((y:R)~(intersection_domaine V (image_dir g [c:R]``a <= c <= b``) y))).
Intro; Elim H9; Intros V H10; Elim H10; Clear H10; Intros.
Unfold voisinage in H10; Elim H10; Intros del H12; Exists del; Intros; Red; Intro; Elim (H11 y).
Unfold intersection_domaine; Unfold intersection_domaine in H13; Elim H13; Clear H13; Intros; Split.
Apply (H12 ? H13).
Apply H14.
Cut ~(point_adherent (image_dir g [c:R]``a <= c <= b``) M).
Intro; Unfold point_adherent in H9.
Assert H10 := (not_all_ex_not ? [V:R->Prop](voisinage V M)
            ->(EXT y:R |
                   (intersection_domaine V
                     (image_dir g [c:R]``a <= c <= b``) y)) H9).
Elim H10; Intros V0 H11; Exists V0; Assert H12 := (imply_to_and ? ? H11); Elim H12; Clear H12; Intros.
Split.
Apply H12.
Apply (not_ex_all_not ? ? H13).
Red; Intro; Cut (adherence (image_dir g [c:R]``a <= c <= b``) M).
Intro; Elim (ferme_P1 (image_dir g [c:R]``a <= c <= b``)); Intros H11 _; Assert H12 := (H11 H3).
Elim H8.
Unfold eq_Dom in H12; Elim H12; Clear H12; Intros.
Apply (H13 ? H10).
Apply H9.
Exists (g a); Unfold image_dir; Exists a; Split.
Reflexivity.
Split; [Right; Reflexivity | Apply H].
Unfold bound; Unfold bornee in H4; Elim H4; Clear H4; Intros m H4; Elim H4; Clear H4; Intros M H4; Exists M; Unfold is_upper_bound; Intros; Elim (H4 ? H5); Intros _ H6; Apply H6.
Apply prolongement_C0; Assumption.
Qed.

(* f continue sur [a,b] est minor�e et atteint sa borne inf�rieure *)
Lemma continuity_ab_min : (f:(R->R); a,b:R) ``a <= b``->((c:R)``a<=c<=b``->(continuity_pt f c))->(EXT mx:R | ((c:R)``a <= c <= b``->``(f mx) <= (f c)``)/\``a <= mx <= b``).
Intros.
Cut ((c:R)``a<=c<=b``->(continuity_pt (opp_fct f0) c)).
Intro; Assert H2 := (continuity_ab_maj (opp_fct f0) a b H H1); Elim H2; Intros x0 H3; Exists x0; Intros; Split.
Intros; Rewrite <- (Ropp_Ropp (f0 x0)); Rewrite <- (Ropp_Ropp (f0 c)); Apply Rle_Ropp1; Elim H3; Intros; Unfold opp_fct in H5; Apply H5; Apply H4.
Elim H3; Intros; Assumption.
Intros.
Assert H2 := (H0 ? H1).
Apply (continuity_pt_opp ? ? H2).
Qed.


(********************************************************)
(*         Proof of Bolzano-Weierstrass theorem         *)
(********************************************************)

Definition ValAdh [un:nat->R;x:R] : Prop := (V:R->Prop;N:nat) (voisinage V x) -> (EX p:nat | (le N p)/\(V (un p))).

Definition intersection_famille [f:famille] : R->Prop := [x:R](y:R)(ind f y)->(f y x).

Lemma ValAdh_un_exists : (un:nat->R) let D=[x:R](EX n:nat | x==(INR n)) in let f=[x:R](adherence [y:R](EX p:nat | y==(un p)/\``x<=(INR p)``)/\(D x)) in ((x:R)(EXT y:R | (f x y))->(D x)).
Intros; Elim H; Intros; Unfold f in H0; Unfold adherence in H0; Unfold point_adherent in H0; Assert H1 : (voisinage (Disque x0 (mkposreal ? Rlt_R0_R1)) x0).
Unfold voisinage Disque; Exists (mkposreal ? Rlt_R0_R1); Unfold inclus; Trivial.
Elim (H0 ? H1); Intros; Unfold intersection_domaine in H2; Elim H2; Intros; Elim H4; Intros; Apply H6.
Qed.

(* Ensemble des valeurs d'adh�rence de (un) *)
Definition ValAdh_un [un:nat->R] : R->Prop := let D=[x:R](EX n:nat | x==(INR n)) in let f=[x:R](adherence [y:R](EX p:nat | y==(un p)/\``x<=(INR p)``)/\(D x)) in (intersection_famille (mkfamille D f (ValAdh_un_exists un))).

(* x est valeur d'adh�rence de (un) ssi x appartient a (ValAdh_un un) *)
Lemma ValAdh_un_prop : (un:nat->R;x:R) (ValAdh un x) <-> (ValAdh_un un x).
Intros; Split; Intro.
Unfold ValAdh in H; Unfold ValAdh_un; Unfold intersection_famille; Simpl; Intros; Elim H0; Intros N H1; Unfold adherence; Unfold point_adherent; Intros; Elim (H V N H2); Intros; Exists (un x0); Unfold intersection_domaine; Elim H3; Clear H3; Intros; Split.
Assumption.
Split.
Exists x0; Split; [Reflexivity | Rewrite H1; Apply (le_INR ? ? H3)].
Exists N; Assumption.
Unfold ValAdh; Intros; Unfold ValAdh_un in H; Unfold intersection_famille in H; Simpl in H; Assert H1 : (adherence [y0:R](EX p:nat | ``y0 == (un p)``/\``(INR N) <= (INR p)``)/\(EX n:nat | ``(INR N) == (INR n)``) x).
Apply H; Exists N; Reflexivity.
Unfold adherence in H1; Unfold point_adherent in H1; Assert H2 := (H1 ? H0); Elim H2; Intros; Unfold intersection_domaine in H3; Elim H3; Clear H3; Intros; Elim H4; Clear H4; Intros; Elim H4; Clear H4; Intros; Elim H4; Clear H4; Intros; Exists x1; Split.
Apply (INR_le ? ? H6).
Rewrite H4 in H3; Apply H3.
Qed.

Lemma adherence_P4 : (F,G:R->Prop) (inclus F G) -> (inclus (adherence F) (adherence G)).
Unfold adherence inclus; Unfold point_adherent; Intros; Elim (H0 ? H1); Unfold intersection_domaine; Intros; Elim H2; Clear H2; Intros; Exists x0; Split; [Assumption | Apply (H ? H3)].
Qed.

Definition famille_ferme [f:famille] : Prop := (x:R) (ferme (f x)).

Definition intersection_vide_in [D:R->Prop;f:famille] : Prop := ((x:R)((ind f x)->(inclus (f x) D))/\~(EXT y:R | (intersection_famille f y))).

Definition intersection_vide_finie_in [D:R->Prop;f:famille] : Prop := (intersection_vide_in D f)/\(famille_finie f).

(* Propri�t� des compacts pour les intersections vides de ferm�s *)
Lemma compact_P6 : (X:R->Prop) (compact X) -> (EXT z:R | (X z)) -> ((g:famille) (famille_ferme g) -> (intersection_vide_in X g) -> (EXT D:R->Prop | (intersection_vide_finie_in X (famille_restreinte g D)))).
Intros X H Hyp g H0 H1.
Pose D' := (ind g).
Pose f' := [x:R][y:R](complementaire (g x) y)/\(D' x).
Assert H2 : (x:R)(EXT y:R|(f' x y))->(D' x).
Intros; Elim H2; Intros; Unfold f' in H3; Elim H3; Intros; Assumption.
Pose f0 := (mkfamille D' f' H2).
Unfold compact in H; Assert H3 : (recouvrement_ouvert X f0).
Unfold recouvrement_ouvert; Split.
Unfold recouvrement; Intros; Unfold intersection_vide_in in H1; Elim (H1 x); Intros; Unfold intersection_famille in H5; Assert H6 := (not_ex_all_not ? [y:R](y0:R)(ind g y0)->(g y0 y) H5 x); Assert H7 := (not_all_ex_not ? [y0:R](ind g y0)->(g y0 x) H6); Elim H7; Intros; Exists x0; Elim (imply_to_and ? ? H8); Intros; Unfold f0; Simpl; Unfold f'; Split; [Apply H10 | Apply H9].
Unfold famille_ouvert; Intro; Elim (classic (D' x)); Intro.
Apply ouvert_P6 with (complementaire (g x)).
Unfold famille_ferme in H0; Unfold ferme in H0; Apply H0.
Unfold f0; Simpl; Unfold f'; Unfold eq_Dom; Split.
Unfold inclus; Intros; Split; [Apply H4 | Apply H3].
Unfold inclus; Intros; Elim H4; Intros; Assumption.
Apply ouvert_P6 with [_:R]False.
Apply ouvert_P4.
Unfold eq_Dom; Unfold inclus; Split; Intros; [Elim H4 | Simpl in H4; Unfold f' in H4; Elim H4; Intros; Elim H3; Assumption].
Elim (H ? H3); Intros SF H4; Exists SF; Unfold intersection_vide_finie_in; Split.
Unfold intersection_vide_in; Simpl; Intros; Split.
Intros; Unfold inclus; Intros; Unfold intersection_vide_in in H1; Elim (H1 x); Intros; Elim H6; Intros; Apply H7.
Unfold intersection_domaine in H5; Elim H5; Intros; Assumption.
Assumption.
Elim (classic (EXT y:R | (intersection_domaine (ind g) SF y))); Intro Hyp'.
Red; Intro; Elim H5; Intros; Unfold intersection_famille in H6; Simpl in H6.
Cut (X x0).
Intro; Unfold recouvrement_fini in H4; Elim H4; Clear H4; Intros H4 _; Unfold recouvrement in H4; Elim (H4 x0 H7); Intros; Simpl in H8; Unfold intersection_domaine in H6; Cut (ind g x1)/\(SF x1).
Intro; Assert H10 := (H6 x1 H9); Elim H10; Clear H10; Intros H10 _; Elim H8; Clear H8; Intros H8 _; Unfold f' in H8; Unfold complementaire in H8; Elim H8; Clear H8; Intros H8 _; Elim H8; Assumption.
Split.
Apply (cond_fam f0).
Exists x0; Elim H8; Intros; Assumption.
Elim H8; Intros; Assumption.
Unfold intersection_vide_in in H1; Elim Hyp'; Intros; Assert H8 := (H6 ? H7); Elim H8; Intros; Cut (ind g x1).
Intro; Elim (H1 x1); Intros; Apply H12.
Apply H11.
Apply H9.
Apply (cond_fam g); Exists x0; Assumption.
Unfold recouvrement_fini in H4; Elim H4; Clear H4; Intros H4 _; Cut (EXT z:R | (X z)).
Intro; Elim H5; Clear H5; Intros; Unfold recouvrement in H4; Elim (H4 x0 H5); Intros; Simpl in H6; Elim Hyp'; Exists x1; Elim H6; Intros; Unfold intersection_domaine; Split.
Apply (cond_fam f0); Exists x0; Apply H7.
Apply H8.
Apply Hyp.
Unfold recouvrement_fini in H4; Elim H4; Clear H4; Intros; Unfold famille_finie in H5; Unfold domaine_fini in H5; Unfold famille_finie; Unfold domaine_fini; Elim H5; Clear H5; Intros l H5; Exists l; Intro; Elim (H5 x); Intros; Split; Intro; [Apply H6; Simpl; Simpl in H8; Apply H8 | Apply (H7 H8)].
Qed.

Lemma MaxRlist_P2 : (l:Rlist) (EXT y:R | (In y l)) -> (In (MaxRlist l) l).
Intros; Induction l.
Simpl in H; Elim H; Trivial.
Induction l.
Simpl; Left; Reflexivity.
Change (In (Rmax r (MaxRlist (cons r0 l))) (cons r (cons r0 l))); Unfold Rmax; Case (total_order_Rle r (MaxRlist (cons r0 l))); Intro.
Right; Apply Hrecl; Exists r0; Left; Reflexivity.
Left; Reflexivity.
Qed.

Theorem Bolzano_Weierstrass : (un:nat->R;X:R->Prop) (compact X) -> ((n:nat)(X (un n))) -> (EXT l:R | (ValAdh un l)).
Intros; Cut (EXT l:R | (ValAdh_un un l)).
Intro; Elim H1; Intros; Exists x; Elim (ValAdh_un_prop un x); Intros; Apply (H4 H2).
Assert H1 : (EXT z:R | (X z)).
Exists (un O); Apply H0.
Pose D:=[x:R](EX n:nat | x==(INR n)).
Pose g:=[x:R](adherence [y:R](EX p:nat | y==(un p)/\``x<=(INR p)``)/\(D x)).
Assert H2 : (x:R)(EXT y:R | (g x y))->(D x).
Intros; Elim H2; Intros; Unfold g in H3; Unfold adherence in H3; Unfold point_adherent in H3.
Assert H4 : (voisinage (Disque x0 (mkposreal ? Rlt_R0_R1)) x0).
Unfold voisinage; Exists (mkposreal ? Rlt_R0_R1); Unfold inclus; Trivial.
Elim (H3 ? H4); Intros; Unfold intersection_domaine in H5; Decompose [and] H5; Assumption.
Pose f0 := (mkfamille D g H2).
Assert H3 := (compact_P6 X H H1 f0).
Elim (classic (EXT l:R | (ValAdh_un un l))); Intro.
Assumption.
Cut (famille_ferme f0).
Intro; Cut (intersection_vide_in X f0).
Intro; Assert H7 := (H3 H5 H6).
Elim H7; Intros SF H8; Unfold intersection_vide_finie_in in H8; Elim H8; Clear H8; Intros; Unfold intersection_vide_in in H8; Elim (H8 R0); Intros _ H10; Elim H10; Unfold famille_finie in H9; Unfold domaine_fini in H9; Elim H9; Clear H9; Intros l H9; Pose r := (MaxRlist l); Cut (D r).
Intro; Unfold D in H11; Elim H11; Intros; Exists (un x); Unfold intersection_famille; Simpl; Unfold intersection_domaine; Intros; Split.
Unfold g; Apply adherence_P1; Split.
Exists x; Split; [Reflexivity | Rewrite <- H12; Unfold r; Apply MaxRlist_P1; Elim (H9 y); Intros; Apply H14; Simpl; Apply H13].
Elim H13; Intros; Assumption.
Elim H13; Intros; Assumption.
Elim (H9 r); Intros.
Simpl in H12; Unfold intersection_domaine in H12; Cut (In r l).
Intro; Elim (H12 H13); Intros; Assumption.
Unfold r; Apply MaxRlist_P2; Cut (EXT z:R | (intersection_domaine (ind f0) SF z)).
Intro; Elim H13; Intros; Elim (H9 x); Intros; Simpl in H15; Assert H17 := (H15 H14); Exists x; Apply H17.
Elim (classic (EXT z:R | (intersection_domaine (ind f0) SF z))); Intro.
Assumption.
Elim (H8 R0); Intros _ H14; Elim H1; Intros; Assert H16 := (not_ex_all_not ? [y:R](intersection_famille (famille_restreinte f0 SF) y) H14); Assert H17 := (not_ex_all_not ? [z:R](intersection_domaine (ind f0) SF z) H13); Assert H18 := (H16 x); Unfold intersection_famille in H18; Simpl in H18; Assert H19 := (not_all_ex_not ? [y:R](intersection_domaine D SF y)->(g y x)/\(SF y) H18); Elim H19; Intros; Assert H21 := (imply_to_and ? ? H20); Elim (H17 x0); Elim H21; Intros; Assumption.
Unfold intersection_vide_in; Intros; Split.
Intro; Simpl in H6; Unfold f0; Simpl; Unfold g; Apply inclus_trans with (adherence X).
Apply adherence_P4.
Unfold inclus; Intros; Elim H7; Intros; Elim H8; Intros; Elim H10; Intros; Rewrite H11; Apply H0.
Apply adherence_P2; Apply compact_P2; Assumption.
Apply H4.
Unfold famille_ferme; Unfold f0; Simpl; Unfold g; Intro; Apply adherence_P3.
Qed.