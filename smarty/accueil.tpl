{include file="head.tpl" titre_page="Espace de saisie de vos activités"}
{if !$u}
	<div>
		<h1>Bienvenue dans l'espace de saisie de vos activités</h1>
		<div style="padding:10px; width:45%;  float:left;">
			<h2>Entrez vos identifiants</h2>
			<form method="post" action="?t=accueil">
				<input type="hidden" name="act" value="login"/>
				Nom d'utilisateur : <br/><input type="text" style="width: 90%;" name="username"/><br/>
				Mot de passe : <br/><input type="password"style="width: 90%;" name="password"/><br/>
				<input type="submit" value="Envoyer"/>
			</form>
			<p>Un compte Clicnat est nécessaire pour se connecter, vous pouvez <a href="http://poste.obs.picardie-nature.org/?t=inscription">créer un compte contributeur</a> si besoin.</p>
			<p>Si vous avez perdu votre mot de passe, vous pouvez en <a href="http://poste.obs.picardie-nature.org/?t=login">demander un nouveau ici</a></p>
			<h2>Tutoriel</h2>
			<div style="text-align: justify;">
				<a style="float:left;" href="tutorial.pdf"><img border=0 src="image/tutorial.png"/></a>Téléchargez ce guide qui vous accompagnera pour votre première contribution au calendrier des actités 100% nature et environnement 100% gratuites en Picardie.<br/><br><a href="tutorial.pdf">Télécharger</a>
			</div>
		</div>
		<div style="padding: 10px; width:45%; float:left; text-align:justify;">
			
			<p>Cet espace vous est dédié à vous, bénévoles de l'association Picardie Nature, souhaitant organiser une action en lien avec la découverte et la protection de la nature et de l'environnement en Picardie.</p>
			<p>L'investissement de chacun d'entre vous permet de traiter des sujets variés, au cœur des préoccupations actuelles, afin de partager votre passion et nos valeurs communes. Ceci permettra d'éveiller le public
			 aux merveilles de la nature et de le mobiliser à la protection de l'environnement.</p>
			<p>De nombreuses activités peuvent être proposées : Sorties, expositions photos, conférences, actions militantes... La liste est ouverte, nous avons besoin de vos idées et nous vous remercions pour votre engagement. </p>
		</div>
		<div style="clear:both;"></div>
	</div>
{else}
	<div>
		<h1>Tableau de bord</h1>
		<div style="font-size: 14px;">
			<div style="float: right; width: 40%; padding: 6px; background-color: white; text-align:justify;">
				Vous souhaitez proposer une activité (sortie nature, exposition, conférence, atelier, stand, inventaire collectif) :
				saissez là dans ce formulaire en ligne (pour des raisons de délais merci de la saisir au moins 1 mois avant sa date de réalisation).
				Une fois validée, elle sera alors diffusée sur notre site internet et d'autres outils de communication de l'association en fonction
				des opportunités. Pour toutes questions, contactez-nous à decouverte@picardie-nature.org ou 03 62 72 22 54
			</div>
			<p> Vous vous trouvez ici sur l'espace vous permettant de suivre l'évolution des activités que vous envisagez.</p>
			<p> Tant que le formulaire pour votre activité est incomplet (s'il manque le descriptif, l'horaire...), celle-ci apparaîtra dans l'onglet « Brouillons ». Vous devrez alors enrichir votre formulaire avant que nous le relisions.</p>
			<p> Lorsque votre proposition apparaît dans l'onglet « En attente », c'est que sa formulation est complète. L'équipe de Picardie Nature pourra alors commencer à traiter votre projet. Tant que votre proposition est dans cet onglet vous pouvez encore à tout moment la modifier.</p>
			<p> Enfin lorsque votre proposition apparaît dans l'onglet « Traitéés » c'est que l'équipe de Picardie Nature a fini de l'examiner.<br/>
			3 appréciations sont possibles :
			<ul>
				<li> ok en cas de validation</li>
				<li>"annulées" en cas de changement de planning</li>
				<li>"non retenues", si votre activité ne correspond pas aux objectifs de l'association.</li>
			</ul>
			</p>
		</div>
		<div style="width:300px; float:left; padding: 4px;">
			<h1>Brouillons</h1>
			{foreach from=$sans_dates item=sortie}
				<div class="item_sortie">
					<a style="float:right;" href="?t=accueil&supprimer_brouillon={$sortie->id_sortie}">supprimer</a>
					<a style="float:left;" href="?t=editer&sortie={$sortie->id_sortie}">{$sortie->nom_lib}</a> 
					<div style="clear:both;"></div>
				</div>
			{/foreach}
		</div>
		<div style="width:300px; float:left; padding: 4px;">
			<h1>En attente</h1>
			{foreach from=$en_attente item=sortie}
				<div class="item_sortie">
					<a href="?t=editer&sortie={$sortie.id_sortie}">{if strlen($sortie.nom) eq 0}sortie sans nom{else}{$sortie.nom}{/if}</a> le 
					<a href="?t=editer_suiv&id_sortie={$sortie.id_sortie}">{$sortie.date_sortie|date_format:"%d-%m-%Y"}</a>
				</div>
			{/foreach}
		</div>
		<div style="width:300px; float:left; padding: 4px;">
			<h1>Traitées</h1>
			<h2>Ok</h2>
			{foreach from=$valides item=sortie}
				<div class="item_sortie">
					<a href="?t=editer&sortie={$sortie.id_sortie}">{$sortie.nom}</a> le 
					<a href="?t=editer_suiv&id_sortie={$sortie.id_sortie}">{$sortie.date_sortie|date_format:"%d-%m-%Y"}</a>
				</div>
			{/foreach}
			<h2>Annulées</h2>
			{foreach from=$annulees item=sortie}
				<div class="item_sortie">
					<a href="?t=editer&sortie={$sortie.id_sortie}">{$sortie.nom}</a> le 
					<a href="?t=editer_suiv&id_sortie={$sortie.id_sortie}">{$sortie.date_sortie|date_format:"%d-%m-%Y"}</a>
				</div>
			{/foreach}
			<h2>Pas retenues</h2>
			{foreach from=$pas_retenues item=sortie}
				<div class="item_sortie">
					<a href="?t=editer&sortie={$sortie.id_sortie}">{$sortie.nom}</a> le 
					<a href="?t=editer_suiv&id_sortie={$sortie.id_sortie}">{$sortie.date_sortie|date_format:"%d-%m-%Y"}</a>
				</div>
			{/foreach}

		</div>
		<div style="clear:both;"></div>
	</div>
{/if}
{include file="foot.tpl"}
